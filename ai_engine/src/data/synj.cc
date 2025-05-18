#include "data/synj.hpp"

#include <fstream>
#include <cstring>
#include <iostream>

namespace SynapseParser
{
  void ISynj::Parse()
  {
    std::ifstream file(m_FilePath, std::ios::binary | std::ios::ate);
    if (!file)
    {
      std::cerr << "Error opening file: " << m_FilePath << std::endl;
      return;
    }

    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    char* synj_data = new char[size];
    file.read(synj_data, size);
    const char* buffer = synj_data;

    std::cout << "Parsing SYNJ with data:\n" << synj_data << std::endl;
    Synj* synj = synj_parser_parse(buffer, size);
    if (synj == nullptr)
    {
      std::cerr << "ERROR: Failed to parse Synj data" << std::endl;
      delete[] synj_data;
      return;
    }

    this->CopyData(synj);
    
    synj_parser_free(synj);
    synj = nullptr;

    this->PrintStats();

    delete[] synj_data;
  }

  void ISynj::CopyData(Synj* synj)
  {
    this->m_ModelName = synj->model_name;
    this->m_Algorithm = synj->model_type == LinearRegression ? ModelType::Linear_Regression : synj->model_type == LogisticRegression ? ModelType::Logistic_Regression : ModelType::Unknown_Model;
    this->m_CSVPath = synj->csv_path;
    this->m_OutputPath = synj->output_path;
    this->m_Target = synj->target;

    this->m_Epochs = synj->epochs;
    this->m_BatchSize = synj->batch_size;
    this->m_LearningRate = synj->learning_rate;

    this->m_Features.clear();
    this->m_Features.reserve(synj->features_len);
    for (size_t i = 0; i < synj->features_len; i++) {
      this->m_Features.push_back(synj->features[i]);
    }

    this->m_Classes.clear();
    this->m_Classes.reserve(synj->classes_len);
    for (size_t i = 0; i < synj->classes_len; i++) {
      this->m_Classes.push_back(synj->classes[i]);
    }

    this->m_EarlyStop.patience = synj->early_stop.patience;

    this->m_TrainTestSplit = { synj->train_test_split[0], synj->train_test_split[1] };
  }

  void ISynj::PrintStats()
  {
    std::cout << std::endl << std::endl;
    std::cout << "Parsed Synj" << std::endl;
    std::cout << "Model Name: \"" << this->m_ModelName << "\"" << std::endl;
    std::cout << "Algorithm: " << (this->m_Algorithm == ModelType::Linear_Regression ? "Linearregression" : "LogisticRegression") << std::endl;
    std::cout << "CSV Path: " << this->m_CSVPath << std::endl;
    std::cout << "Target: " << this->m_Target << std::endl;
    std::cout << "Train Test Split: [" << (int)this->m_TrainTestSplit[0] << ", " << (int)this->m_TrainTestSplit[1] << "]" << std::endl;
    std::cout << "Features: [";
    for (size_t i = 0; i < this->m_Features.size(); i++) {
      std::cout << "\"" << this->m_Features[i] << "\"";
      if (i < this->m_Features.size()-1)
        std::cout << ", ";
    }
    std::cout << "]" << std::endl;
    std::cout << "Classes: [";
    for (size_t i = 0; i < this->m_Classes.size(); i++) {
      std::cout << "\"" << this->m_Classes[i] << "\"";
      if (i < this->m_Classes.size()-1)
        std::cout << ", ";
    }
    std::cout << "]" << std::endl;
    std::cout << "Epochs: " << this->m_Epochs << std::endl;
    std::cout << "Learning Rate: " << this->m_LearningRate << std::endl;
    std::cout << "Batch Size: " << this->m_BatchSize << std::endl;
    std::cout << "Early Stop Patience: " << this->m_EarlyStop.patience << std::endl;
    std::cout << "Output Path: " << this->m_OutputPath << std::endl;
    std::cout << std::endl << std::endl;
  }
};
