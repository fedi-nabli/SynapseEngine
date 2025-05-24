#ifndef __SYNAPSE_MATH_INPUT_H_
#define __SYNAPSE_MATH_INPUT_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

typedef enum ModelType
{
  LinearRegression = 0,
  MultiLinearRegression = 1,
} ModelType;

typedef struct MathInput
{
  uint32_t epochs;
  uint32_t batch_size;
  uint32_t early_stop;
  double learning_rate;
  ModelType model_type;
  uint32_t train_rows;
  uint32_t train_cols;
  const double* train_features;
  const double* train_target;
  uint32_t test_rows;
  uint32_t test_cols;
  const double* test_features;
  const double* test_target;
} MathInput;

#ifdef __cplusplus
}
#endif

#endif