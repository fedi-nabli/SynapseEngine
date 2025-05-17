/*
 * json.h - Header file for JSON parsing library
 *
 * This file defines the structures and functions used for parsing JSON files.
 * The library provides functionality to parse a JSON
 * buffer and manage the parsed data.
 * 
 * Author: Fedi Nabli
 * Date: 7 May 2025
 * Last Modified: 17 May 2025
 */

#ifndef __JSON_H_
#define __JSON_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stddef.h>

typedef struct
{
  char* schema_version;
  char* run_id;
  char* model_name;
  char* model_type;
  char* target;
  double final_loss;
  double* weights;
  size_t _weights_len;
  
  double bias;
  uint32_t epochs_trained;
} Json;

Json* json_parser_parse(const char* buffer, size_t buffer_len);
void json_parser_free(Json* json);

#ifdef __cplusplus
}
#endif

#endif