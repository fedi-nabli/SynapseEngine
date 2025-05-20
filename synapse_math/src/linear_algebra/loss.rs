/// linear_algebra/loss.rs - Math Engine Loss Structs
/// 
/// This file defines different Loss functions and
/// their gradients for Linear Algebra
/// 
/// Author: Fedi Nabli
/// Date: 20 May 2025
/// Last Modified: 20 May 2025

use crate::math::{ln, Scalar, Vector};
use crate::error::Error;

pub trait Loss {
  fn loss(pred: &Vector, target: &Vector) -> Result<Scalar, Error>;
  fn grad(pred: &Vector, target: &Vector) -> Result<Vector, Error>;
}

pub struct MSE;
impl Loss for MSE {
  fn loss(pred: &Vector, target: &Vector) -> Result<Scalar, Error> {
      mse(pred, target)
  }
  
  fn grad(pred: &Vector, target: &Vector) -> Result<Vector, Error> {
      mse_grad(pred, target)
  }
}

pub struct CrossEntropy;
impl Loss for CrossEntropy {
  fn loss(pred: &Vector, target: &Vector) -> Result<Scalar, Error> {
      cross_entropy(pred, target)
  }

  fn grad(pred: &Vector, target: &Vector) -> Result<Vector, Error> {
      cross_entropy_grad(pred, target)
  }
}

/// Mean Squared Error: (1/n) * SUM(pred_i - target_i)^2
fn mse(pred: &Vector, target: &Vector) -> Result<Scalar, Error> {
  let n = pred.len();
  if n != target.len() {
    return Err(Error::VectorDimensionMismatch);
  }

  if n == 0 {
    return Err(Error::VectorDimensionMismatch);
  }

  let sum_sq = pred.data.iter()
    .zip(&target.data)
    .map(|(&p, &t)| {
      let d = p - t;
      d * d
    })
    .sum::<Scalar>();

  Ok(sum_sq / (n as Scalar))
}

/// Gradient of MSE. predictions: (2/n)*(pred - target)
fn mse_grad(pred: &Vector, target: &Vector) -> Result<Vector, Error> {
  let n = pred.len();
  if n != target.len() {
    return Err(Error::VectorDimensionMismatch);
  }

  if n == 0 {
    return Err(Error::VectorDimensionMismatch);
  }

  let factor = 2.0 / (n as Scalar);
  let mut grad = Vector::zeroes(n);
  for idx in 0..n {
    let p = pred.get(idx).unwrap();
    let t = target.get(idx).unwrap();
    grad.set(idx, factor * (p - t))?;
  }

  Ok(grad)
}

/// Cross Entropy Loss: -(1/n) * SUM([Ti * ln(Pi)])
fn cross_entropy(pred: &Vector, target: &Vector) -> Result<Scalar, Error> {
  let n = pred.len();
  if n != target.len() {
    return Err(Error::VectorDimensionMismatch);
  }

  if n == 0 {
    return Err(Error::VectorDimensionMismatch);
  }

  let sum_ce = pred.data.iter()
    .zip(&target.data)
    .map(|(&p, &t)| {
      if p <= 0.0 {
        return Err(Error::InsufficientData);
      }
      Ok(t * ln(p))
    })
    .collect::<Result<Vec<Scalar>, Error>>()?
    .iter()
    .sum::<Scalar>();

  Ok(-sum_ce / (n as Scalar))
}

/// Gradient of Cross Entropy: predictions: -(1/n)*(Ti / Pi)
fn cross_entropy_grad(pred: &Vector, target: &Vector) -> Result<Vector, Error> {
  let n = pred.len();
  if n != target.len() {
    return Err(Error::VectorDimensionMismatch);
  }

  if n == 0 {
    return Err(Error::VectorDimensionMismatch);
  }

  let inv_n = 1.0 / (n as Scalar);
  let mut grad = Vector::zeroes(n);

  for idx in 0..n {
    let p = pred.get(idx).unwrap();
    let t = target.get(idx).unwrap();
    if p <= 0.0 {
      return Err(Error::InsufficientData);
    }
    grad.set(idx, -inv_n * (t / p))?;
  }
  
  Ok(grad)
}
