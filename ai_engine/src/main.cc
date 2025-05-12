/*
 * main.cc - AI Engine C++ Entry point
 * 
 * This file implements the main function for
 * synapse binary and is the orchestrator of the project
 * 
 * Author: Fedi Nabli
 * Date: 8 May 2025
 * Last Updated: 10 May 2025
 */

#include "iostream"

#include "data/csv.hpp"

#include "json.h"
#include <string>

int main()
{
  std::cout << "Hello World!" << std::endl;

  std::string csv_path = "./tests/test.csv";
  SynapseParser::ICSV csv_parser(csv_path);
  csv_parser.Parse();

  const char* buf = "{\"test\": \"working\", \n\"run_id\": \"123_54\"}";
  size_t len = strlen(buf);
  Json* json = json_parser_parse(buf, len);
  json_parser_free(json);

  return 0;
}