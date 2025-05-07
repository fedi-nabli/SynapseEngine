#############################
### Add Script Test       ###
### Date: 7 May 2025      ###
### Author: Fedi Nabli    ###
#############################

function(add_script_test name)
  add_test(NAME ${name} COMMAND ${ARGN})
endfunction()
