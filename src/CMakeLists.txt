cmake_minimum_required(VERSION 3.10)
project(ucode_native_modules C)

# Automatically find all .c files in this directory
file(GLOB SOURCES CONFIGURE_DEPENDS "*.c")
message(STATUS "Found sources: ${SOURCES}")

foreach(SRC ${SOURCES})
    get_filename_component(LIBNAME ${SRC} NAME_WE)
    
    # Create a shared library for each .c file
    add_library(${LIBNAME} SHARED ${SRC})
    
    # Remove the "lib" prefix (so we get mymodule.so, not libmymodule.so)
    set_target_properties(${LIBNAME} PROPERTIES PREFIX "")
    
    install(TARGETS ${LIBNAME} DESTINATION lib/ucode)
endforeach()
