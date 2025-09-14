cmake_minimum_required(VERSION 3.22)

# LANGUAGESキーワードを正しく使用
project(JUCEwithCMake VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# UTF-8対応
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    add_compile_options(/utf-8)
endif()

# JUCEを追加
add_subdirectory(lib/JUCE)

# プラグインを定義
juce_add_plugin(
    JUCEwithCMake
    COMPANY_NAME "Gaku Fujii"                    
    COMPANY_COPYRIGHT "Gaku Fujii"
    COMPANY_WEBSITE "https://intwist.carrd.co/"
    COMPANY_EMAIL "intmainwist@gmail.com"
    BUNDLE_ID "com.GakuFujii.JUCEwithCMake"      # ここを追加（空白なし）
    IS_SYNTH FALSE                              
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT FALSE
    IS_MIDI_EFFECT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE
    COPY_PLUGIN_AFTER_BUILD TRUE
    PLUGIN_MANUFACTURER_CODE GaFu
    PLUGIN_CODE Jwcm
    FORMATS 
        Standalone 
        VST3 
    VST3_CATEGORIES "Fx"
    MICROPHONE_PERMISSION_ENABLED TRUE
    MICROPHONE_PERMISSION_TEXT "This application requires permission to use an audio input device."
    PRODUCT_NAME "JUCE with CMake")

# ソースファイルを追加
target_sources(
    JUCEwithCMake
    PRIVATE
        src/PluginEditor.cpp
        src/PluginProcessor.cpp
)

# インクルードディレクトリを設定
target_include_directories(
    JUCEwithCMake
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# コンパイル定義
target_compile_definitions(
    JUCEwithCMake
    PUBLIC
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0
        JUCE_DISPLAY_SPLASH_SCREEN=0
)

# JUCEモジュールをリンク
target_link_libraries(
    JUCEwithCMake
    PUBLIC
        juce::juce_audio_basics
        juce::juce_audio_devices
        juce::juce_audio_formats
        juce::juce_audio_plugin_client
        juce::juce_audio_processors
        juce::juce_audio_utils
        juce::juce_core
        juce::juce_data_structures
        juce::juce_dsp
        juce::juce_events
        juce::juce_graphics
        juce::juce_gui_basics
)

# プリコンパイルヘッダーを設定
target_precompile_headers(JUCEwithCMake
    PRIVATE
        <JuceHeader.h>
)

# JUCEヘッダーを生成
juce_generate_juce_header(JUCEwithCMake)