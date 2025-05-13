/*
 * json.cc - AI Engine C++ JSON Class Implementation
 * 
 * This file implements the C++ JSON Class' functions
 * 
 * Author: Fedi Nabli
 * Date: 13 May 2025
 * Last Updated: 13 May 2025
 */

#include "data/json.hpp"

#include <fstream>
#include <cstring>
#include <iostream>

namespace SynapseParser
{
  void IJson::Parse()
  {
    std::ifstream file(m_FilePath, std::ios::binary | std::ios::ate);
    if (!file)
    {
      std::cerr << "Error opening file: " << m_FilePath << std::endl;
      return;
    }

    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    char* json_data = new char[size];
    file.read(json_data, size);
    const char* buffer = json_data;

    std::cout << "Parsing JSON with data:\n" << json_data << std::endl;
    Json* json = json_parser_parse(buffer, size);
    if (json == nullptr)
    {
      std::cerr << "ERROR: Failed to parse Json data" << std::endl;
      delete[] json_data;
      return;
    }

    this->CopyData(json);

    json_parser_free(json);
    json = nullptr;

    this->PrintStats();

    delete[] json_data;
  }

  void IJson::CopyData(Json* json)
  {
    this->m_SchemaVersion = json->schema_version;
    this->m_RunID = json->run_id;
    this->m_ModelName = json->model_name;
    this->m_ModelType = json->model_type;
    this->m_Target = json->target;

    this->m_EpochsTrained = json->epochs_trained;
    this->m_FinalLoss = json->final_loss;
    this->m_Bias = json->bias;

    if (json->weights != nullptr)
    {
      this->m_Weights.clear();

      size_t i = 0;
      while (json->weights[i] != 0.0)
      {
        this->m_Weights.push_back(json->weights[i]);
        i++;
      }
    }
  }

  void IJson::PrintStats()
  {
    std::cout << std::endl;
    std::cout << "Parsed Json:" << std::endl;
    std::cout << "Schema Version: " << this->m_SchemaVersion << std::endl;
    std::cout << "Run ID: " << this->m_RunID << std::endl;
    std::cout << "Model Name: " << this->m_ModelName << std::endl;
    std::cout << "Model Type: " << this->m_ModelType << std::endl;
    std::cout << "Target: " << this->m_Target << std::endl;
    std::cout << "Epochs Trained: " << this->m_EpochsTrained << std::endl;
    std::cout << "Final Loss: " << this->m_FinalLoss << std::endl;
    
    std::cout << "Weights: [";
    for (size_t i = 0; i < this->m_Weights.size(); i++)
    {
      std::cout << this->m_Weights[i];
      if (i < this->m_Weights.size() - 1)
        std::cout << ", ";
    }
    std::cout << "]" << std::endl;

    std::cout << "Bias: " << this->m_Bias << std::endl;
  }
}
