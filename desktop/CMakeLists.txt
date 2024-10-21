cmake_minimum_required(VERSION 3.12)

project(multi_tag_datasync_background)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 啟用 AUTOMOC
set(CMAKE_AUTOMOC ON)

# Find the Qt package
find_package(Qt5 COMPONENTS Core Widgets REQUIRED)

set(
    Source_Files 
    src/main.cpp
    src/mainwindow.cpp
    resources.qrc
)

qt5_add_resources(RESOURCES resources.qrc)

add_executable(${PROJECT_NAME} ${Source_Files} ${RESOURCES})

# Include Qt headers
target_include_directories(${PROJECT_NAME} PRIVATE ${Qt5Widgets_INCLUDE_DIRS})

# Link Qt libraries
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Widgets)
