/// linear_algebra/gradient.rs - Math Engine Gradient Structs
/// 
/// This file defines different Gradient functions and
/// Optimizers for the train loop
/// 
/// Author: Fedi Nabli
/// Date: 20 May 2025
/// Last Modified: 20 May 2025

use crate::math::{Scalar, Vector};
use crate::error::Error;

pub fn numeric_grad<F>(f: F, params: &Vector, eps: Scalar) -> Vector
where
  F: Fn(&Vector) -> Scalar,
{
  let n = params.len();
  let mut grad = Vector::zeroes(n);

  for idx in 0..n {
    let mut theta_plus = params.clone();
    let mut theta_minus = params.clone();
    theta_plus.set(idx, params.get(idx).unwrap() + eps).unwrap();
    theta_minus.set(idx, params.get(idx).unwrap() - eps).unwrap();

    let f_plus = f(&theta_plus);
    let f_minus = f(&theta_minus);
    let derivative = (f_plus - f_minus) / (2.0 * eps);

    grad.set(idx, derivative).unwrap();
  }

  grad
}

pub trait Optimizer {
  fn update(&mut self, params: &mut Vector, grad: &Vector) -> Result<(), Error>;
}

pub struct SGD {
  pub lr: Scalar,
}

impl Optimizer for SGD {
  fn update(&mut self, params: &mut Vector, grad: &Vector) -> Result<(), Error> {
    let n = params.len();
    if n != grad.len() {
      return Err(Error::VectorDimensionMismatch);
    }

    for idx in 0..n {
      let p = params.get(idx).unwrap();
      let g = grad.get(idx).unwrap();
      params.set(idx, p - self.lr * g)?;
    } 

    Ok(())
  }
}

pub struct Momentum {
  pub lr: Scalar,
  pub momentum: Scalar,
  pub velocity: Vector,
}

impl Optimizer for Momentum {
  fn update(&mut self, params: &mut Vector, grad: &Vector) -> Result<(), Error> {
    let n = params.len();
    if n != grad.len() || n != self.velocity.len() {
      return Err(Error::MatrixIndexOutOfBounds);
    }

    for idx in 0..n {
      let v_prev = self.velocity.get(idx).unwrap();
      let g = grad.get(idx).unwrap();
      let v_new = self.momentum * v_prev + self.lr * g;
      self.velocity.set(idx, v_new)?;
      let p = params.get(idx).unwrap();
      params.set(idx, p - v_new)?;
    }

    Ok(())
  }
}

pub struct Adam {
  pub lr: Scalar,
  pub beta1: Scalar,
  pub beta2: Scalar,
  pub eps: Scalar,
  pub m: Vector,
  pub v: Vector,
  pub t: usize,
}

impl Optimizer for Adam {
  fn update(&mut self, params: &mut Vector, grad: &Vector) -> Result<(), Error> {
    let n = params.len();
    if n != grad.len() || n != self.m.len() || n != self.v.len() {
      return Err(Error::VectorDimensionMismatch);
    }

    self.t += 1;
    let t_f = self.t as Scalar;

    for idx in 0..n {
      let g = grad.get(idx).unwrap();
      let m_prev = self.m.get(idx).unwrap();
      let v_prev = self.v.get(idx).unwrap();

      // Update bias first & second moments
      let m_new = self.beta1 * m_prev + (1.0 - self.beta1) * g;
      let v_new = self.beta2 * v_prev + (1.0 - self.beta2) * (g * g);
      self.m.set(idx, m_new)?;
      self.v.set(idx, v_new)?;

      // Compute bias-corrected moments
      let m_hat = m_new / (1.0 - self.beta1.powf(t_f));
      let v_hat = v_new / (1.0 - self.beta2.powf(t_f));

      // Update parameters
      let p = params.get(idx).unwrap();
      let update = self.lr * m_hat / (v_hat.sqrt() + self.eps);
      params.set(idx, p - update)?;
    }

    Ok(())
  }
}
