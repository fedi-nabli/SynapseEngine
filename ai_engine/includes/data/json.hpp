#pragma once

#include <vector>
#include <string>
#include <cstdint>

#include "json.h"

namespace SynapseParser
{
  class IJson
  {
    public:
      IJson(std::string filepath)
        : m_FilePath(filepath) {}
      
      ~IJson() {}

      void Parse();

    private:
      void CopyData(Json* json);

      void PrintStats();

    private:
      std::string m_FilePath;
      std::string m_Filename;

      std::string m_SchemaVersion;
      std::string m_RunID;
      std::string m_ModelName;
      std::string m_ModelType;
      std::string m_Target;
      
      uint32_t m_EpochsTrained;
      double m_FinalLoss;
      double m_Bias;

      std::vector<double> m_Weights;
  };
};
