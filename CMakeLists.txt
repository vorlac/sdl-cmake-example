cmake_minimum_required(VERSION 3.22)
set(CMAKE_MESSAGE_LOG_LEVEL STATUS)

list(APPEND CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)

include(submodule-init)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)
set(CMAKE_DIRECTORY_LABELS ON)

project(sdl_project
  LANGUAGES
    C CXX
  VERSION
    0.0.1
)

option(
  AUTOFORMAT_SRC_ON_CONFIGURE
    "If enabled, clang-format will be used to format all sources in src/ during configuration"
      OFF # ON
)

set(FORCE_STATIC_VCRT OFF)
set(BUILD_SHARED_LIBS OFF)

# SDL build options
set(SDL_LIBC OFF)
set(SDL_VULKAN ON)
set(SDL_SHARED OFF)
set(SDL_STATIC ON)

set(SDL_TESTS OFF)
set(SDL_TEST_LIBRARY OFF)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/extern/sdl")

file(GLOB_RECURSE
  project_sources
    CONFIGURE_DEPENDS
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.[hc]"
      "${CMAKE_CURRENT_SOURCE_DIR}/src/*.[hc]pp"
)

add_executable(${PROJECT_NAME}
  ${project_sources}
)

target_compile_features(${PROJECT_NAME} PRIVATE
  PRIVATE
    cxx_std_23
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
  NOMINMAX
  WIN32_LEAN_AND_MEAN
  VC_EXTRALEAN

  $<$<CONFIG:Debug>:
      # debug only msvc defs
  >

  $<$<CONFIG:Release>:
      # release only msvc defs
  >
)

target_compile_options(${PROJECT_NAME} PRIVATE
  $<$<CONFIG:Debug>:
      # debug only compiler options
  >
  
  $<$<CONFIG:Release>:
      # release only compiler options
  >
)

target_include_directories(${PROJECT_NAME}
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE $<TARGET_NAME_IF_EXISTS:SDL2::SDL2main>
    PRIVATE $<IF:$<TARGET_EXISTS:SDL2::SDL2>,SDL2::SDL2,SDL2::SDL2-static>
)

add_custom_command(TARGET ${PROJECT_NAME}
  POST_BUILD COMMAND
    ${CMAKE_COMMAND} -E copy_directory_if_different
      ${CMAKE_CURRENT_SOURCE_DIR}/resources
      $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources
)

if (AUTOFORMAT_SRC_ON_CONFIGURE MATCHES ON)
  # Formatting rules defined by .clangformat
  # Scoped to src/*.[h]pp and src/*.[c]pp
  include(clang-format)
endif()

include(utils)
