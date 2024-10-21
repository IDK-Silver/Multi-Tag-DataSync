cmake_minimum_required(VERSION 3.12)

project(multi_tag_datasync_background)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(
    Source_Files 
    src/main.cpp
)

add_executable(${PROJECT_NAME} ${Source_Files})