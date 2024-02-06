cmake_minimum_required(VERSION 3.27.8)

project(Hello)

set(SOURCE_FILES_DIR "../src")
set(SOURCE_FILES ${SOURCE_FILES_DIR}/main.cc)

add_executable(Hello ${SOURCE_FILES})
