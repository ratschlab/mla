cmake_minimum_required(VERSION 3.26)
project(PLAST CXX)

add_executable(PLAST PLAST.cpp)
target_compile_features(PLAST PUBLIC cxx_std_11)
target_compile_options(PLAST PUBLIC -static -march=core-avx2 -pthread -Wall -O3)
target_link_libraries(PLAST PUBLIC -static bifrost/lib/libbifrost.a -lz -lpthread)
target_include_directories(PLAST PUBLIC bifrost/include/)
