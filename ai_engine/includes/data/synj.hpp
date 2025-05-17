#pragma once

#include <array>
#include <string>
#include <vector>
#include <cstdint>

#include "synj.h"

namespace SynapseParser
{
  enum class ModelType {
    Linear_Regression,
    Logistic_Regression,
    Unknown_Model
  };

  struct IEarlyStop {
    uint32_t patience;
  };

  class ISynj
  {
    public:
      ISynj(std::string filepath)
        : m_FilePath(filepath) {}

      ~ISynj() {}

      void Parse();
      bool Validate();

    private:
      void CopyData(Synj* synj);

      void PrintStats();

    private:
      std::string m_FilePath;
      std::string m_FileName;

      std::string m_ModelName;
      ModelType m_Algorithm;

      std::string m_CSVPath;
      std::string m_OutputPath;

      std::string m_Target;
      std::vector<std::string> m_Features;
      std::vector<std::string> m_Classes;
      
      uint32_t m_Epochs;
      uint32_t m_BatchSize;
      double m_LearningRate;

      IEarlyStop m_EarlyStop;

      std::array<uint8_t, 2> m_TrainTestSplit;
  };
};
