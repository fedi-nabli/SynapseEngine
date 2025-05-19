/// math/mod.rs - Math Engine Math module
/// 
/// This module exposes core math data types and
/// functions with their different functions
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025


pub mod scalar;
pub mod vector;
pub mod matrix;
pub mod elem;

pub use scalar::Scalar;
pub use vector::Vector;
pub use matrix::Matrix;

pub use elem::{exp, ln, sqrt, abs, cos, sin, tan, cosh, sinh, tanh};
