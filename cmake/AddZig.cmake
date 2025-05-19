#############################
### Add Zig Function      ###
### Date: 7 May 2025      ###
### Author: Fedi Nabli    ###
#############################

function(add_zig_library target project_dir)
  set(ZIG_OUT ${CMAKE_CURRENT_BINARY_DIR}/zig-out)

  file(MAKE_DIRECTORY ${ZIG_OUT}/lib)
  file(MAKE_DIRECTORY ${ZIG_OUT}/include)

  add_custom_command(
    OUTPUT ${ZIG_OUT}/lib/lib${target}.a
           ${ZIG_OUT}/include/${target}.h
    COMMAND zig build -Doptimize=ReleaseFast
            --cache-dir ${CMAKE_CURRENT_BINARY_DIR}/zig-cache
            --prefix ${ZIG_OUT}
    WORKING_DIRECTORY ${project_dir}
    COMMENT "Building Zig project ${target}"
    USES_TERMINAL
    VERBATIM
  )

  add_custom_target(${target}_gen DEPENDS ${ZIG_OUT}/lib/lib${target}.a)

  add_library(${target} STATIC IMPORTED GLOBAL)
  set_target_properties(${target} PROPERTIES
    IMPORTED_LOCATION ${ZIG_OUT}/lib/lib${target}.a
    INTERFACE_INCLUDE_DIRECTORIES ${ZIG_OUT}/include
  )

    add_dependencies(${target} ${target}_gen)
endfunction()
