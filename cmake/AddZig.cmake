#############################
### Add Zig Function      ###
### Date: 7 May 2025      ###
### Author: Fedi Nabli    ###
#############################

function(add_zig_library target source)
  set(ARCHIVE ${CMAKE_CURRENT_BINARY_DIR}/${target}.a)
  set(HEADER ${CMAKE_CURRENT_BINARY_DIR}/${target}.h)

  add_custom_command(
    OUTPUT ${ARCHIVE} ${HEADER}
    COMMAND zig build-lib
            -O ReleaseFast
            -femit-h=${HEADER}
            -femit-bin=${ARCHIVE}
            -fPIC
            -target native
            ${source}
    DEPENDS ${source}
    COMMENT "Building Zig static library ${target}"
    USES_TERMINAL
    VERBATIM
  )

  add_custom_target(${target}_gen DEPENDS ${ARCHIVE})

  add_library(${target} STATIC IMPORTED GLOBAL)
  set_target_properties(${target} PROPERTIES
    IMPORTED_LOCATION ${ARCHIVE}
    INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_BINARY_DIR}
  )

  add_dependencies(${target} ${target}_gen)
endfunction()
