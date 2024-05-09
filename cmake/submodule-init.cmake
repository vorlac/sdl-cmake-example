# SDL2 submodule init/update
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/extern/sdl/src")
    message(NOTICE "SDL2 submodule sources not found")
    message(NOTICE "initializing/updating the SDL submodule...")
    execute_process(
        COMMAND git submodule update --init extern/sdl
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()
