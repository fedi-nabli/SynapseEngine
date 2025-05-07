#include <iostream>

#include "csv.h"
#include "json.h"
#include "synj.h"

#include "math/synapse_math.h"

int main()
{
  std::cout << "Hello World!" << std::endl;
  std::cout << add(3, 2) << std::endl;
  std::cout << add_json(5, 3) << std::endl;
  std::cout << add_synj(8, 2) << std::endl;
  std::cout << add_rust(10, 2) << std::endl;
  return 0;
}