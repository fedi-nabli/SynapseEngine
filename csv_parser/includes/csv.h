/*
 * csv.h - Header file for CSV parsing library
 *
 * This file defines the structures and functions used for parsing CSV files.
 * It includes support for handling headers, rows, and data values of different
 * types (integer and float). The library provides functionality to parse a CSV
 * buffer and manage the parsed data.
 * 
 * Author: Fedi Nabli
 * Date: 8 May 2025
 * Last Modified: 9 May 2025
 */

#ifndef __CSV_H_
#define __CSV_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef enum {
  INTEGER,
  FLOAT
} DataType;

typedef union {
  int64_t int_val;
  double float_val;
} NumValue;

typedef struct {
  NumValue value;
  DataType dtype;
} Number;

typedef struct {
  size_t num_cols;
  Number* values;
  size_t _values_len;
} Row;

typedef struct {
  size_t num_rows;
  Row* rows;
  void* _padding;
} Data;

typedef struct {
  char** col_names;
  size_t num_cols;
} Header;

typedef struct CSV {
  char* terminator;
  Header header;
  Data data;
  char seperator;
  char _padding[7];
};

CSV* csv_parser_parse(const char* buffer_ptr, size_t buffer_len, char sep);
void csv_parser_free(CSV* csv);
// bool csv_parser_deinit();

#ifdef __cplusplus
}
#endif

#endif