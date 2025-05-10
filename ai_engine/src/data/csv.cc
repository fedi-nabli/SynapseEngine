#include "data/csv.hpp"

#include <fstream>
#include <cstring>
#include <iostream>

namespace SynapseParser
{
  void ICSV::Parse()
  {
    std::ifstream file(m_FilePath, std::ios::binary | std::ios::ate);
    if (!file)
    {
      std::cerr << "Error opening file: " << m_FilePath << std::endl;
      return;
    }

    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    char* csv_data = new char[size];
    file.read(csv_data, size);
    const char* buffer = csv_data;

    std::cout << "Parsing CSV with data:\n" << csv_data << std::endl;
    CSV* csv = csv_parser_parse(buffer, size, 0);
    if (csv == nullptr)
    {
      std::cerr << "ERROR: Failed to parse CSV data" << std::endl;
      delete[] csv_data;
      return;
    }

    this->CopyData(csv);

    this->PrintStats();

    csv_parser_free(csv);
    csv = nullptr;

    delete[] csv_data;
  }

  bool ICSV::Validate()
  {
    // Check if we have any data
    if (m_Data.empty() || m_NumCols == 0)
      return false;

    // Check is header size matches column count
    if (m_Header.size() != m_NumCols)
      return false;

    for (size_t i = 0; i < m_Data.size(); i++)
    {
      if (m_Data[i].size() != m_NumCols)
        return false;
    }

    return true;
  }

  void ICSV::PrintStats()
  {
    std::cout << "\nParsed CSV:" << std::endl;

    std::cout << "Seperator: " << m_Seperator << std::endl;
    std::cout << "Header Stats:" << std::endl;
    std::cout << "Header Column Number: " << m_NumCols << std::endl; 

    if (m_NumCols > 0 && !m_Header.empty())
    {
      std::cout << "Column Names:" << std::endl;
      for (size_t i = 0; i < m_NumCols; i++)
      {
        if (!m_Header[i].empty())
        {
          std::cout << "\"" << m_Header[i] << "\"";
        }
        else
        {
          std::cout << "<null>";
        }

        if (i < m_NumCols - 1)
          std::cout << ", ";
      }
      std::cout << std::endl << std::endl;
    }

    std::cout << "Data Stats:" << std::endl;
    std::cout << "Rows Number: " << m_NumRows << std::endl;

    if (m_NumRows > 0 && !m_Data.empty())
    {
      std::cout << "\nRows Data:" << std::endl;
      for (size_t i = 0; i < m_Data.size(); i++)
      {
        std::cout << "Row " << i+1 << " (" << m_Data[i].size() << " cols): ";
        for (size_t j = 0; j < m_Data[i].size(); j++)
        {
          const Value& value = m_Data[i][j];
          if (value.dtype == ValueType::Integer)
          {
            std::cout << value.int_value;
          }
          else if (value.dtype == ValueType::Float)
          {
            std::cout << value.float_value;
          }
          else
          {
            std::cout << "<unknown type>";
          }

          if (j < m_Data[i].size() - 1)
            std::cout << ", ";
        }
        std::cout << std::endl;
      }
    }
  }

  void ICSV::CopyData(CSV* csv)
  {
    this->m_Seperator = csv->seperator;
    this->m_NumCols = csv->header.num_cols;
    this->m_NumRows = csv->data.num_rows;

    // Clear existing header data
    m_Header.clear();

    if (csv->header.col_names != nullptr)
    {
      for (size_t i = 0; i < csv->header.num_cols; i++)
      {
        if (csv->header.col_names[i] != nullptr)
        {
          m_Header.push_back(std::string(csv->header.col_names[i]));
        }
      }
    }

    // Clear and resize data vector
    m_Data.clear();
    m_Data.resize(this->m_NumRows);

    // Copy row data
    for (size_t i = 0; i < this->m_NumRows; i++)
    {
      Row& csv_row = csv->data.rows[i];
      m_Data[i].reserve(csv_row.num_cols);

      for (size_t j = 0; j < csv_row.num_cols; j++)
      {
        Value value;
        if (csv_row.values[j].dtype == INTEGER)
        {
          value.dtype = ValueType::Integer;
          value.int_value = csv_row.values[j].value.int_val;
        }
        else
        {
          value.dtype = ValueType::Float;
          value.float_value = csv_row.values[j].value.float_val;
        }

        m_Data[i].push_back(value);
      }
    }
  }
};
