/// linear_algebra/actiation.rs - Math Engine Activation Structs
/// 
/// This file defines different Activation functions and
/// their gradients for Linear Algebra
/// 
/// Author: Fedi Nabli
/// Date: 20 May 2025
/// Last Modified: 20 May 2025

use crate::math::{self, exp, scalar::neg, Scalar};

pub trait Activation {
  fn forward(x: Scalar) -> Scalar;
  fn backward(x: Scalar) -> Scalar;
}

pub struct ReLU;
impl Activation for ReLU {
  #[inline]
  fn forward(x: Scalar) -> Scalar {
    relu(x)
  }

  #[inline]
  fn backward(x: Scalar) -> Scalar {
    relu_grad(x)
  }
}

pub struct Sigmoid;
impl Activation for Sigmoid {
  #[inline]
  fn forward(x: Scalar) -> Scalar {
    sigmoid(x)
  }

  #[inline]
  fn backward(x: Scalar) -> Scalar {
    sigmoid_grad(x)
  }
}

pub struct Tanh;
impl Activation for Tanh {
  #[inline]
  fn forward(x: Scalar) -> Scalar {
    tanh(x)
  }

  #[inline]
  fn backward(x: Scalar) -> Scalar {
    tanh_grad(x)
  }
}

#[inline]
fn relu(x: Scalar) -> Scalar { x.max(0.0) }

#[inline]
fn relu_grad(x: Scalar) -> Scalar { if x > 0.0 { 1.0 } else { 0.0 } }

#[inline]
fn sigmoid(x: Scalar) -> Scalar { 1.0 / (1.0 + (exp(neg(x)))) }

#[inline]
fn sigmoid_grad(x: Scalar) -> Scalar { sigmoid(x) * (1.0 - sigmoid(x)) }

#[inline]
fn tanh(x: Scalar) -> Scalar { math::tanh(x) }

#[inline]
fn tanh_grad(x: Scalar) -> Scalar { 1.0 - math::tanh(x).powi(2) }

// TODO: Implement softmax and softmax_jacobian
// TODO: Add Vector Activation functions
