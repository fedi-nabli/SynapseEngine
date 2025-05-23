/// models/linear_regressions.rs - Math Engine LinearRegression model
/// 
/// This file defines the LinearRegression model functions
/// 
/// Author: Fedi Nabli
/// Date: 23 May 2025
/// Last Modified: 23 May 2025

use crate::rand::Random;
use crate::solver::Solver;
use crate::linear_algebra::MSE;
use crate::math::{Scalar, Vector, Matrix};
use crate::ffi::InternalInput;
use crate::error::Error;

use super::Model;

pub struct LinearRegression {
  pub weights: Vector,
  pub bias: Scalar,
}

impl LinearRegression {
  /// Standard deviation for initial weights/bias
  const INIT_STD: Scalar = 0.01;
}

impl Model for LinearRegression {
  type LossFn = MSE;

  fn init(input: &InternalInput) -> Self {
    let n_features = input.train_x.cols;
    let mut rng = Random::new(None);

    LinearRegression {
      weights: rng.normal_vector(n_features, 0.0, Self::INIT_STD),
      bias: rng.normal_scalar(0.0, Self::INIT_STD),
    }
  }

  fn train(&mut self, input: &InternalInput) -> Result<(), Error> {
    let mut solver = Solver::<Self>::new(input.clone());
    solver.train()?;

    self.weights = solver.model.weights;
    self.bias = solver.model.bias;

    Ok(())
  }

  fn test(&self, input: &InternalInput) -> Result<Scalar, Error> {
    let solver = Solver::<Self>::new(input.clone());
    solver.test()
  }

  fn predict(&self, x: Matrix) -> Result<Vector, Error> {
    // Compute X * weights (vector multiplication)
    let mut out = x.vec_mul(&self.weights)?;
    // Add bias term
    for val in out.data.iter_mut() {
      *val += self.bias;
    }
    Ok(out)
  }

  fn update(&mut self, x: &Matrix, grad_pred: &Vector, lr: Scalar) -> Result<(), Error> {
    let batch_size = x.rows as Scalar;
    let xt = x.transpose();
    let mut grad_w = xt.vec_mul(grad_pred)?;
    // Sum of per-example
    let mut grad_b: Scalar = grad_pred.data.iter().copied().sum();

    // Average over the batch
    for gw in grad_w.data.iter_mut() {
      *gw /= batch_size;
    }
    grad_b /= batch_size;

    // Gradient descent step
    for idx in 0..self.weights.len() {
      let w = self.weights.get(idx).unwrap();
      let gw = grad_w.get(idx).unwrap();
      self.weights.set(idx, w - lr * gw)?;
    }
    self.bias -= lr * grad_b;

    Ok(())
  }
}
