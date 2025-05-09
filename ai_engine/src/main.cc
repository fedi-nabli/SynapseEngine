#include <cstring>
#include <iostream>
#include <fstream>

#include "csv.h"
#include "json.h"
#include "synj.h"

#include "math/synapse_math.h"

int main()
{
  std::cout << "Hello World!" << std::endl;

  std::string csv_path = "./tests/test.csv";
  std::ifstream file(csv_path, std::ios::binary | std::ios::ate);
  if (!file)
  {
    std::cerr << "Error opening file: " << csv_path << std::endl;
    return -1;
  }
  std::streamsize size = file.tellg();
  file.seekg(0, std::ios::beg);

  char* csv_file = new char[size];
  file.read(csv_file, size);
  const char* buffer = csv_file;

  size_t len = strlen(csv_file);
  std::cout << "Testing CSV parser with data:\n" << csv_file << std::endl;
  CSV* csv = csv_parser_parse(buffer, len, 0);
  if (csv == NULL)
  {
    std::cout << "ERROR: Failed to parse CSV data" << std::endl;
    return -1;
  }

  std::cout << "\nParsed CSV:\n" << std::endl;

  std::cout << "Seperator: " << csv->seperator << std::endl;
  std::cout << "Header Stats:" << std::endl;
  std::cout << "Header Columns Number: " << csv->header.num_cols << std::endl;

  if (csv->header.num_cols > 0 && csv->header.col_names != nullptr)
  {
    std::cout << "Column Names: " << std::endl;
    for (size_t i = 0; i < csv->header.num_cols; i++)
    {
      if (csv->header.col_names[i] != nullptr)
      {
        std::cout << "\"" << csv->header.col_names[i] << "\"";
      }
      else
      {
        std::cout << "<null>";
      }

      if (i < csv->header.num_cols - 1)
        std::cout << ", ";
    }

    std::cout << std::endl << std::endl;
  }

  std::cout << "Data Stats:" << std::endl;
  std::cout << "Row Number: " << csv->data.num_rows << std::endl;

  // Display the actual data rows
  if (csv->data.num_rows > 0 && csv->data.rows != nullptr)
  {
    std::cout << "\nData Rows:" << std::endl;
    for (size_t i = 0; i < csv->data.num_rows; i++)
    {
      Row& row = csv->data.rows[i];
      std::cout << "Row " << i + 1 << " (" << row.num_cols << " columns): ";
      
      if (row.values != nullptr)
      {
        // Make sure we don't try to access more elements than exist
        size_t cols_to_show = row.num_cols;
        
        for (size_t j = 0; j < cols_to_show; j++)
        {
          const Number& num = row.values[j];
          if (num.dtype == INTEGER)
          {
            std::cout << num.value.int_val;
          }
          else if (num.dtype == FLOAT)
          {
            std::cout << num.value.float_val;
          }
          else
          {
            std::cout << "<unknown type>";
          }
          
          if (j < cols_to_show - 1)
          {
            std::cout << ", ";
          }
        }
      }
      else
      {
        std::cout << "<null values>";
      }
      
      std::cout << std::endl;
    }
  }

  // Don't forget to free the memory
  csv_parser_free(csv);

  return 0;
}