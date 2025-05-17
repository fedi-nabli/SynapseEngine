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

#include "synj.h"
#include <string>

int main()
{
  std::cout << "Hello World!" << std::endl;

  const char* buffer = "model_name = \"Iris Flowers\";\nalgorithm = LinearRegression;\ncsv_path = \"data/iris.csv\";\ntrain_test_split = [80, 20];\ntarget = \"species\";\nfeatures = [\"sepal_length\", \"sepal_width\", \"petal_length\", \"petal_width\"];\nclasses = [\"setosa\", \"versicolor\", \"virginica\"];\nepochs = 100;\nlearning_rate = 0.01;\nbatch_size = 32;\nearly_stop = { \"patience\": 10 };\noutput_path = \"output/model.json\";";
  size_t len = strlen(buffer);

  std::cout << "Parsing SYNJ with:" << std::endl;
  std::cout << buffer << std::endl << std::endl << std::endl;
  Synj* synj = synj_parser_parse(buffer, len);

  std::cout << std::endl << std::endl;
  std::cout << "Parsed Stats:" << std::endl;
  std::cout << "Model Name: " << synj->model_name << std::endl;
  std::cout << "Algorithm: " << (synj->model_type == LinearRegression ? "LinearRegression" : "LogisticRegression") << std::endl;
  std::cout << "CSV Data Path: " << synj->csv_path << std::endl;
  std::cout << "Target: " << synj->target << std::endl;
  std::cout << "Train Test Split: [" << (int)synj->train_test_split[0] << ", " << (int)synj->train_test_split[1] << "]" << std::endl;
  std::cout << "Features Len: " << synj->features_len << std::endl;
  std::cout << "Features: [" << std::endl;
  for (size_t idx = 0; idx < synj->features_len; idx++) {
    std::cout << "\"" << synj->features[idx] << "\"";
    if (idx < synj->features_len-1)
      std::cout << ", ";
    std::cout << std::endl;
  }
  std::cout << "]" << std::endl;;
  std::cout << "Classes Len: " << synj->classes_len << std::endl;
  std::cout << "Classes: [" << std::endl;
  for (size_t idx = 0; idx < synj->classes_len; idx++) {
    std::cout << "\"" << synj->classes[idx] << "\"";
    if (idx < synj->classes_len-1)
      std::cout << ", ";
    std::cout << std::endl;
  }
  std::cout << "]" << std::endl;
  std::cout << "Epochs: " << synj->epochs << std::endl;
  std::cout << "Learning Rate: " << synj->learning_rate << std::endl;
  std::cout << "Batch Size: " << synj->batch_size << std::endl;
  std::cout << "Early Stop Patience: " << synj->early_stop.patience << std::endl;
  std::cout << "Output Path: " << synj->output_path << std::endl;
  std::cout << std::endl << std::endl;

  synj_parser_free(synj);

  std::string csv_path = "./tests/test.csv";
  SynapseParser::ICSV csv_parser(csv_path);
  csv_parser.Parse();
  std::cout << std::endl << std::endl;

  std::string json_path = "./tests/model.json";
  SynapseParser::IJson json_parser(json_path);
  json_parser.Parse();

  return 0;
}