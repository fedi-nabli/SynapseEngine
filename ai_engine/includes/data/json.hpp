/*
 * json.hpp - AI Engine C++ JSON Class Header
 * 
 * This file defines the C++ JOSN Class and function interfaces
 * 
 * Author: Fedi Nabli
 * Date: 13 May 2025
 * Last Updated: 13 May 2025
 */

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

      inline std::string GetSchemaVersion() const { return m_SchemaVersion; };
      inline std::string GetRunID() const { return m_RunID; };
      inline std::string GetModelName() const { return m_ModelName; };
      inline std::string GetModelType() const { return m_ModelType; };
      inline std::string GetTarget() const { return m_Target; };
      inline uint32_t GetEpochsTrained() const { return m_EpochsTrained; };
      inline double GetFinalLoss() const { return m_FinalLoss; };
      inline double GetBias() const { return m_Bias; };
      inline std::vector<double> GetWeights() const { return m_Weights; };
      inline double GetWeightByIndex(std::size_t idx)
      {
        if (idx >= m_Weights.size() || idx < 0)
        {
          throw std::out_of_range("Item Index out of range");
        }

        return m_Weights[idx];
      };

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
