/// ffi/math_input.rs - Math Engine FFI Input module
/// 
/// This file defines the input structure compatible with C
/// and the Rust internal structure
/// 
/// Author: Fedi Nabli
/// Date: 22 May 2025
/// Last Modified: 22 May 2025

use core::slice;

use crate::math::{Matrix, Vector};

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub enum ModelType {
  LinearRegression = 0,
  MultiLinearRegression = 1,
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct MathInput {
  pub epochs: u32,
  pub batch_size: u32,
  pub early_stop: u32,
  pub learning_rate: f64,
  pub model_type: ModelType,
  pub train_rows: u32,
  pub train_cols: u32,
  pub train_features: *const f64,
  pub train_target: *const f64,
  pub test_rows: u32,
  pub test_cols: u32,
  pub test_features: *const f64,
  pub test_target: *const f64,
}

pub struct InternalInput {
  pub epochs: u32,
  pub batch_size: u32,
  pub early_stop: u32,
  pub learning_rate: f64,
  pub model_type: ModelType,
  pub train_x: Matrix,
  pub train_y: Vector,
  pub test_x: Matrix,
  pub test_y: Vector,
}

impl MathInput {
  pub unsafe fn to_internal(&self) -> InternalInput {
    let tr = self.train_rows as usize;
    let tc = self.train_cols as usize;
    let feat_slice = unsafe { slice::from_raw_parts(self.train_features, tr * tc) };
    let target_slice = unsafe {  slice::from_raw_parts(self.train_target, tr) };

    let train_x = Matrix { rows: tr, cols: tc, data: feat_slice.to_vec() };
    let train_y = Vector { data: target_slice.to_vec() };

    let nr = self.test_rows as usize;
    let nc = self.test_cols as usize;
    let x_slice = unsafe { slice::from_raw_parts(self.test_features, nr * nc) };
    let y_slice = unsafe { slice::from_raw_parts(self.test_target, nr) };

    let test_x = Matrix { rows: nr, cols: nc, data: x_slice.to_vec() };
    let test_y = Vector { data: y_slice.to_vec() };

    let batch_size = if self.batch_size == 0 {
      self.train_rows
    } else {
      self.batch_size
    };

    InternalInput {
      epochs: self.epochs,
      batch_size: batch_size,
      early_stop: self.early_stop,
      learning_rate: self.learning_rate,
      model_type: self.model_type,
      train_x,
      train_y,
      test_x,
      test_y,
    }
  }
}
