/*
 * main.cc - AI Engine C++ Entry point
 * 
 * This file implements the main function for
 * synapse binary and is the orchestrator of the project
 * 
 * Author: Fedi Nabli
 * Date: 8 May 2025
 * Last Updated: 17 May 2025
 */

#include "iostream"

#include "data/csv.hpp"
#include "data/json.hpp"
#include "data/synj.hpp"

int main()
{
  std::cout << "Hello World!" << std::endl;

  std::string csv_path = "./tests/ctf.csv";
  SynapseParser::ICSV csv_parser(csv_path);
  csv_parser.Parse();
  std::cout << std::endl << std::endl;

  std::string json_path = "./tests/model.json";
  SynapseParser::IJson json_parser(json_path);
  json_parser.Parse();
  std::cout << std::endl << std::endl;

  std::string synj_path = "./tests/ctf_config.synj";
  SynapseParser::ISynj synj_parser(synj_path);
  synj_parser.Parse();

  return 0;
}