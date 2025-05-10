/*
 * csv.hpp - AI Engine C++ CSV Class Header
 * 
 * This file defines the C++ CSV Class and function interfaces
 * 
 * Author: Fedi Nabli
 * Date: 10 May 2025
 * Last Updated: 10 May 2025
 */

#pragma once

#include <string>
#include <vector>

#include "csv.h"

namespace SynapseParser
{
  enum class ValueType
  {
    Integer,
    Float
  };

  struct Value
  {
    union
    {
      int64_t int_value;
      double float_value;
    };
    ValueType dtype;
  };

  class ICSV
  {
    public:
      ICSV(std::string filepath)
        : m_FilePath(filepath) {}

      ~ICSV() {};

      void Parse();
      bool Validate();

    private:
      void PrintStats();
      void CopyData(CSV* csv);

    private:
      char m_Seperator;
      std::string m_Terminator;

      std::vector<std::string> m_Header;
      std::vector<std::vector<Value>> m_Data;

      std::string m_Filename;
      std::string m_FilePath;
      uint m_NumCols;
      uint m_NumRows;
  };
};