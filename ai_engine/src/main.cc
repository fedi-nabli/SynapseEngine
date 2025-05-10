#include "iostream"

#include "data/csv.hpp"

int main()
{
  std::cout << "Hello World!" << std::endl;

  std::string csv_path = "./tests/test.csv";
  SynapseParser::ICSV csv_parser(csv_path);
  csv_parser.Parse();

  return 0;
}