/*
 * synj.h - Header file for SYNJ parsing library
 *
 * This file defines the structures and functions used for parsing SYNJ files.
 * The library provides functionality to parse a SYNJ
 * buffer and manage the parsed data.
 * 
 * Author: Fedi Nabli
 * Date: 7 May 2025
 * Last Modified: 17 May 2025
 */

#ifndef __SYNJ_H_
#define __SYNJ_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stddef.h>

typedef uint8_t ModelType;
#define LinearRegression 0
#define LogisticRegression 1

typedef struct __attribute__((packed)) {
  uint32_t patience;
} EarlyStop;

typedef struct __attribute__((packed)) {
  const char* model_name;
  const char* csv_path;
  const char* target;
  const char** features;
  size_t features_len;
  const char** classes;
  size_t classes_len;
  double learning_rate;
  const char* output_path;
  uint32_t epochs;
  uint32_t batch_size;
  EarlyStop early_stop;
  ModelType model_type;
  uint8_t train_test_split[2];
  uint8_t _end_padding;
} Synj;

Synj* synj_parser_parse(const char* buffer, size_t buffer_len);
void synj_parser_free(Synj* synj);

#ifdef __cplusplus
}
#endif

#endif