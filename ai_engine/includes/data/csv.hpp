/*
 * csv.hpp - AI Engine C++ CSV Class Header
 * 
 * This file defines the C++ CSV Class and function interfaces
 * 
 * Author: Fedi Nabli
 * Date: 10 May 2025
 * Last Updated: 11 May 2025
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

      ~ICSV() {}

      void Parse();
      bool Validate();

      inline std::size_t GetNumCols() const { return m_NumCols; };
      inline std::size_t GetNumRows() const { return m_NumRows; };
      inline const std::vector<Value>& GetRowByIndex(size_t idx) const
      {
        if (idx >= m_Data.size())
        {
          throw std::out_of_range("Row index out of bounds");
        }

        return m_Data[idx];
      };

      inline const std::vector<Value> GetColumnByIndex(size_t idx) const
      {
        if (idx >= m_NumCols)
        {
          throw std::out_of_range("Column index out of bounds");
        }

        std::vector<Value> column;
        column.reserve(m_NumRows);

        for (const auto& row : m_Data)
        {
          if (idx < row.size())
          {
            column.push_back(row[idx]);
          }
        }

        return column;
      }

      inline const std::vector<Value> GetColumnByName(const std::string& name) const
      {
        auto it = std::find(m_Header.begin(), m_Header.end(), name);
        if (it == m_Header.end())
        {
          throw std::out_of_range("Column name not found");
        }

        size_t idx = std::distance(m_Header.begin(), it);
        return GetColumnByIndex(idx);
      }

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
      std::size_t m_NumCols;
      std::size_t m_NumRows;
  };
};