# Synapse Engine

Welcome to the official Synapse AI Engine official repository.

## Overview

Synapse AI Engine is a new initiative aimed to simplify AI models training, generation and inference for newcomers and education.

## Stack

The project uses a mixture of Zig, C, C++ and Rust for different components and uses CMake as the central build system.

## Composition

The Project is devided into 3 layers:

- Parsers for CSV, JSON and SYNJ using Zig
- Math engine optimized for NEON/SIMD using Rust
- AI Engine as the main orchestrator using C++
- Perl, Python and Shell scripts for ease of setup and use

The different folders correspond to different parts of the project as listed below

- ai_engine: C++ AI Engine orchestrator
- cmake: Contains CMake files for configuration and setup of project
- csv_parser: Zig CSV parsers supporting string for headers and numerical values only for data
- json_parser: Zig that parses the output json file to recreate the same ai model
- synj_parser: SYNJ DSL parser made using Zig
- synapse_math: Rust Math engine for Linear Algebra and SIMD operations
- scripts: Contains important scripts for setting up and verifying tools needed for this project
- docs: Contains important documentation for the project such as LICENSE, CODE OF CONDUCT...
- examples: Contains different example for the DSL and relevant examples

## SYNJ

SYNJ is a DSL (Domain Specific Language) aiming to reduce the frontier of AI modeling to newcomers, student and hobbiests. The language (as shown below) defines the model, architecture and different parameters for the AI model.

```code
model_name = "Iris Flowers";
algorithm = LinearRegression;
csv_file = "data/iris.csv";
train_test_split = [80, 20];
target = "flower_class";
features = [
  "petal_length",
  "petal_width",
  "sepal_length",
  "sepal_width"
];
classes = ["setosa", "nacrimosa"];
epochs = 10;
learning_rate = 0.01;
batch_size = NULL;
early_stop = { "patience": 5 };
```

## Contact

If you have any questions or need more details please don't hesitate to contact me at:

Email: `fedinabli@gmail.com`

[LinkedIn](https://www.linkedin.com/in/fedi-nabli-76670219a/)

[Facebook](https://www.facebook.com/fedi.nabli.3)
