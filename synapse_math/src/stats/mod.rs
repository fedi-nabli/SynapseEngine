/// stats/mod.rs - Math Engine Stats module
/// 
/// This module exposes core statistics functions
/// 
/// Author: Fedi Nabli
/// Date: 20 May 2025
/// Last Modified: 20 May 2025

pub mod stats;

pub use stats::{mean, variance, std_dev, normalize, covariance, correlation};
