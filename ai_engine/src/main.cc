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

#include "json.h"
#include <string>

int main()
{
  std::cout << "Hello World!" << std::endl;

  std::string csv_path = "./tests/test.csv";
  SynapseParser::ICSV csv_parser(csv_path);
  csv_parser.Parse();
  std::cout << std::endl << std::endl;

  const char* buf = "{\n  \"schema_version\": \"0.1.0\", \n  \"run_id\": \"123_54\", \n  \"model_name\": \"iris flowers\", \n  \"model_type\": \"LinearRegression\", \n  \"target\": \"flower_class\", \n  \"epochs_trained\": 10, \n  \"final_loss\": 0.41, \n  \"weights\": [3.2, 1.5], \n  \"bias\": 32\n}";
  std::cout << "JSON Data:" << std::endl;
  std::cout << buf << std::endl << std::endl;
  
  size_t len = strlen(buf);
  Json* json = json_parser_parse(buf, len);
  std::cout << "Schema version: " << json->schema_version << std::endl;
  std::cout << "Run ID: " << json->run_id << std::endl;
  std::cout << "Model Name: " << json->model_name << std::endl;
  std::cout << "Model Type: " << json->model_type << std::endl;
  std::cout << "Target: " << json->target << std::endl;
  std::cout << "Epochs Trained: " << json->epochs_trained << std::endl;
  std::cout << "Final Loss: " << json->final_loss << std::endl;
  std::cout << "Weights[0]: " << json->weights[0] << std::endl;
  std::cout << "Weights[1]: " << json->weights[1] << std::endl;
  std::cout << "Bias: " << json->bias << std::endl;
  json_parser_free(json);

  return 0;
}