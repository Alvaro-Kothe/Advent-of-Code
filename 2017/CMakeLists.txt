cmake_minimum_required(VERSION 3.27.7)
project(AoC-2017 C)

add_compile_options(-Wall -Wextra -Wpedantic)
set(CMAKE_BUILD_TYPE Debug)

add_executable(day01 src/day01.c)
add_executable(day02 src/day02.c)
add_executable(day03 src/day03.c)
add_executable(day04 src/day04.c)
add_executable(day05 src/day05.c)
