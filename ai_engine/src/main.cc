/*
 * main.cc - AI Engine C++ Entry point
 * 
 * This file implements the main function for
 * synapse binary and is the orchestrator of the project
 * 
 * Author: Fedi Nabli
 * Date: 8 May 2025
 * Last Updated: 12 May 2025
 */

#include "iostream"

#include "data/csv.hpp"
#include "data/json.hpp"

int main()
{
  std::cout << "Hello World!" << std::endl;

  std::string csv_path = "./tests/test.csv";
  SynapseParser::ICSV csv_parser(csv_path);
  csv_parser.Parse();
  std::cout << std::endl << std::endl;

  std::string json_path = "./tests/model.json";
  SynapseParser::IJson json_parser(json_path);
  json_parser.Parse();

  return 0;
}