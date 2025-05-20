/// linear_algebra/mod.rs - Math Engine Linear Lagebra module
/// 
/// This module exposes core Linear algebra functions
/// such as Loss, Activation and Gradient
/// 
/// Author: Fedi Nabli
/// Date: 20 May 2025
/// Last Modified: 20 May 2025


pub mod loss;
pub mod gradient;
pub mod activation;

pub use loss::{MSE, CrossEntropy};
pub use gradient::{SGD, Momentum, Adam};
pub use activation::{ReLU, Sigmoid, Tanh};
