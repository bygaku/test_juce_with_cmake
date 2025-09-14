Write-Host "Reorganizing project structure..." -ForegroundColor Green

# 1. Create include directory
New-Item -ItemType Directory -Force -Path include | Out-Null

# 2. Check for existing headers
$hasHeaders = Test-Path "src/*.h"

if ($hasHeaders) {
    # Move header files to include
    Write-Host "Moving header files..." -ForegroundColor Yellow
    Move-Item -Path "src/*.h" -Destination "include/" -Force
} else {
    # Generate header files
    Write-Host "Generating header files..." -ForegroundColor Yellow
    
    # Create PluginProcessor.h
    $processorHeader = @'
#pragma once

#include <JuceHeader.h>

class PluginAudioProcessor : public juce::AudioProcessor
{
public:
    PluginAudioProcessor();
    ~PluginAudioProcessor() override;

    void prepareToPlay (double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;

   #ifndef JucePlugin_PreferredChannelConfigurations
    bool isBusesLayoutSupported (const BusesLayout& layouts) const override;
   #endif

    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override;

    const juce::String getName() const override;

    bool acceptsMidi() const override;
    bool producesMidi() const override;
    bool isMidiEffect() const override;
    double getTailLengthSeconds() const override;

    int getNumPrograms() override;
    int getCurrentProgram() override;
    void setCurrentProgram (int index) override;
    const juce::String getProgramName (int index) override;
    void changeProgramName (int index, const juce::String& newName) override;

    void getStateInformation (juce::MemoryBlock& destData) override;
    void setStateInformation (const void* data, int sizeInBytes) override;

private:
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PluginAudioProcessor)
};
'@
    $processorHeader | Out-File -FilePath "include/PluginProcessor.h" -Encoding UTF8

    # Create PluginEditor.h
    $editorHeader = @'
#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

class PluginEditor : public juce::AudioProcessorEditor
{
public:
    PluginEditor (PluginAudioProcessor&);
    ~PluginEditor() override;

    void paint (juce::Graphics&) override;
    void resized() override;

private:
    PluginAudioProcessor& audioProcessor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PluginEditor)
};
'@
    $editorHeader | Out-File -FilePath "include/PluginEditor.h" -Encoding UTF8
}

# 3. Update include paths in source files
Write-Host "Updating include paths in source files..." -ForegroundColor Yellow

# Update PluginProcessor.cpp
if (Test-Path "src/PluginProcessor.cpp") {
    $content = Get-Content "src/PluginProcessor.cpp" -Raw -Encoding UTF8
    $content = $content -replace '#include\s+"PluginProcessor\.h"', '#include "PluginProcessor.h"'
    $content = $content -replace '#include\s+"PluginEditor\.h"', '#include "PluginEditor.h"'
    $content | Out-File -FilePath "src/PluginProcessor.cpp" -Encoding UTF8 -NoNewline
}

# Update PluginEditor.cpp if exists
if (Test-Path "src/PluginEditor.cpp") {
    $content = Get-Content "src/PluginEditor.cpp" -Raw -Encoding UTF8
    $content = $content -replace '#include\s+"PluginProcessor\.h"', '#include "PluginProcessor.h"'
    $content = $content -replace '#include\s+"PluginEditor\.h"', '#include "PluginEditor.h"'
    $content | Out-File -FilePath "src/PluginEditor.cpp" -Encoding UTF8 -NoNewline
}

# 4. Show current structure
Write-Host "`nCurrent project structure:" -ForegroundColor Cyan
Get-ChildItem -Path . -Recurse -Depth 2 | Where-Object {
    $_.FullName -notlike "*\.git*" -and 
    $_.FullName -notlike "*\build\*" -and
    $_.FullName -notlike "*\lib\JUCE\extras*" -and
    $_.FullName -notlike "*\lib\JUCE\examples*"
} | ForEach-Object {
    $relativePath = $_.FullName.Replace((Get-Location).Path + "\", "")
    if ($_.PSIsContainer) {
        Write-Host "DIR: $relativePath" -ForegroundColor Yellow
    } else {
        Write-Host "FILE: $relativePath" -ForegroundColor Cyan
    }
}

Write-Host "`nDone!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Magenta
Write-Host "1. Update CMakeLists.txt" -ForegroundColor White
Write-Host "2. Remove build directory: Remove-Item -Recurse -Force build" -ForegroundColor White
Write-Host "3. Configure CMake: cmake -G 'Visual Studio 17 2022' -A x64 -S . -B build" -ForegroundColor White
Write-Host "4. Build: cmake --build build --config Debug" -ForegroundColor White