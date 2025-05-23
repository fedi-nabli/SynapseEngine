/// models/models.rs - Math Engine Model trait
/// 
/// This file defines the model trait and their
/// important functions
/// 
/// Author: Fedi Nabli
/// Date: 23 May 2025
/// Last Modified: 23 May 2025

use crate::linear_algebra::loss::Loss;
use crate::math::{Matrix, Vector, Scalar};
use crate::ffi::InternalInput;
use crate::error::Error;

pub trait Model {
  type LossFn: Loss;

  /// Build parameters and initializes the model
  fn init(input: &InternalInput) -> Self;
  /// Run the full training loop
  fn train(&mut self, input: &InternalInput) -> Result<(), Error>;
  /// Evaluate the chosen metric
  fn test(&self, input: &InternalInput) -> Result<Scalar, Error>;
  /// Run raw inference on *any* matrix of features
  fn predict(&self, x: Matrix) -> Result<Vector, Error>;
  /// Update model parameters
  fn update(&mut self, x: &Matrix, grad_pred: &Vector, lr: Scalar) -> Result<(), Error>;
}
