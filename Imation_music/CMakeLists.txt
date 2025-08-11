cmake_minimum_required(VERSION 3.16)

project(Imation_music VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 明确查找所需模块，包括Svg
find_package(Qt6 REQUIRED COMPONENTS Quick Svg)

qt_standard_project_setup(REQUIRES 6.8)

# 生成可执行文件
qt_add_executable(appImation_music
    main.cpp
)

# 添加QML模块（仅包含QML文件，不包含资源文件）
qt_add_qml_module(appImation_music
    URI Imation_music
    VERSION 1.0
    QML_FILES
        # Main.qml
)

# 关键：使用Qt6推荐的qt6_add_resources处理资源文件，
# 否则无法将资源文件作为项目的一部分导致无法打开对应的资源文件
qt6_add_resources(RESOURCE_FILES res.qrc qml.qrc)

# 将资源文件链接到目标
target_sources(appImation_music PRIVATE ${RESOURCE_FILES})

# 目标属性设置
set_target_properties(appImation_music PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 链接必要的库（包括Svg库用于SVG图片）
target_link_libraries(appImation_music
    PRIVATE Qt6::Quick Qt6::Svg
)

# 安装配置
include(GNUInstallDirs)
install(TARGETS appImation_music
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
