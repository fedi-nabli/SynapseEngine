/// rand.rs - Math Engine Random module
/// 
/// This file defines a Random struct with different
/// helper functions for Scalar, Vector and Matrix
/// 
/// Author: Fedi Nabli
/// Date: 21 May 2025
/// Last Modified: 21 May 2025

use rand::{Rng, SeedableRng};
use rand::rngs::{StdRng};
use rand_distr::{Normal, Uniform};

use crate::math::{Matrix, Scalar, Vector};

pub struct Random {
  rng: StdRng,
}

impl Random {
  /// Create a new RNG: if `seed` is provided, use deterministic seed,
  /// otherwise seeds from the operating system
  pub fn new(seed: Option<u64>) -> Self {
    let rng = match seed {
      Some(s) => StdRng::seed_from_u64(s),
      None => StdRng::from_os_rng(),
    };

    Random { rng }
  }

  /// Draw a single Scalar uniformaly in (low, high)
  pub fn uniform_scalar(&mut self, low: Scalar, high: Scalar) -> Scalar {
    self.rng.sample(Uniform::new(low, high).unwrap())
  }

  /// Draw a single Scalar from Normal(mean, stddev)
  pub fn normal_scalar(&mut self, mean: Scalar, std: Scalar) -> Scalar {
    self.rng.sample(Normal::new(mean, std).unwrap())
  }

  /// Create a vector of length len with entries Uniform(low, high)
  pub fn uniform_vector(&mut self, len: usize, low: Scalar, high: Scalar) -> Vector {
    let mut vec = Vector::zeroes(len);

    for idx in 0..len {
      vec.set(idx, self.uniform_scalar(low, high)).unwrap();
    }

    vec
  }

  /// Create a vector of length len with entries Normal(mean, stddev)
  pub fn normal_vector(&mut self, len: usize, mean: Scalar, std: Scalar) -> Vector {
    let mut vec = Vector::zeroes(len);

    for idx in 0..len {
      vec.set(idx, self.normal_scalar(mean, std)).unwrap();
    }

    vec
  }

  /// Draw a Matrix with shape (rows, cols) with Uniform entries
  pub fn uniform_matrix(&mut self, rows: usize, cols: usize, low: Scalar, high: Scalar) -> Matrix {
    let mut mat = Matrix::zeros(rows, cols);

    for i in 0..rows {
      for j in 0..cols {
        mat.set(i, j, self.uniform_scalar(low, high)).unwrap();
      }
    }

    mat
  }

  /// Draw a Matrix with shape (rows, cols) with Normal entries
  pub fn normal_matrix(&mut self, rows: usize, cols: usize, mean: Scalar, std: Scalar) -> Matrix {
    let mut mat = Matrix::zeros(rows, cols);

    for i in 0..rows {
      for j in 0..cols {
        mat.set(i, j, self.normal_scalar(mean, std)).unwrap();
      }
    }

    mat
  } 
}
