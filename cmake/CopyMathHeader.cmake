function(copy_math_header TARGET_NAME HEADER_NAME SOURCE_DIR)
  set(HEADER_SRC "${SOURCE_DIR}/${HEADER_NAME}.h")
  set(HEADER_DST "${CMAKE_BINARY_DIR}/include/math/${HEADER_NAME}.h")

  add_custom_command(
    OUTPUT ${HEADER_DST}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${HEADER_SRC}
            ${HEADER_DST}
    DEPENDS ${HEADER_SRC}
    COMMENT "Copy ${HEADER_NAME}.h to build/include/math"
    USES_TERMINAL
    VERBATIM
  )

  set(HEADER_TARGET "${TARGET_NAME}_${HEADER_NAME}_header")
  add_custom_target(${HEADER_TARGET} DEPENDS ${HEADER_DST})
  add_dependencies(${TARGET_NAME} ${HEADER_TARGET})
endfunction()