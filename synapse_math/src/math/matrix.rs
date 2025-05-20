/// math/matrix.rs - Math Engine Matrix type
/// 
/// This file defines the Matrix structure
/// and exposes important functionalities for
/// the data type
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

use super::{scalar, Scalar, Vector};

use crate::error::Error;

pub struct Matrix {
  pub rows: usize,
  pub cols: usize,
  pub data: Vec<Scalar>
}

impl Matrix {
  pub fn zeros(rows: usize, cols: usize) -> Matrix {
    Matrix {
      cols,
      rows,
      data: vec![scalar::zero(); rows * cols]
    }
  }

  pub fn ones(rows: usize, cols: usize) -> Matrix {
    Matrix {
      cols,
      rows,
      data: vec![scalar::one(); rows * cols]
    }
  }

  pub fn identity(len: usize) -> Matrix {
    let mut mat = Matrix::zeros(len, len);
    for i in 0..len {
      for j in 0..len {
        if i == j {
          mat.data[i * len + j] = scalar::one();
        }
      }
    }

    return mat;
  }

  pub fn shape(&self) -> (usize, usize) {
    return (self.rows, self.cols);
  }

  pub fn get(&self, row: usize, col: usize) -> Option<Scalar> {
    if row >= self.rows || col >= self.cols {
      return None;
    }

    match self.data.get(row * self.cols + col) {
      Some(&value) => Some(value),
      None => None,
    }
  }

  pub fn set(&mut self, row: usize, col: usize, s: Scalar) -> Result<(), Error> {
    if row >= self.rows || col >= self.cols {
      return Err(Error::MatrixIndexOutOfBounds);
    }

    self.data[row * self.cols + col] = s;

    Ok(())
  }

  pub fn transpose(&self) -> Matrix {
    let mut trans_mat = Matrix::zeros(self.cols, self.rows);

    for i in 0..self.rows {
      for j in 0..self.cols {
        trans_mat.data[j * self.rows + i] = self.data[i * self.cols + j];
      }
    }

    trans_mat
  }

  pub fn mat_mul(&self, other: &Matrix) -> Result<Matrix, Error> {
    if self.cols != other.rows {
      return Err(Error::MatDimensionMismatch);
    }

    let mut new_mat = Matrix::zeros(self.rows, other.cols);

    for i in 0..self.rows {
      for j in 0..other.cols {
        let mut sum = scalar::zero();
        for k in 0..self.cols {
          sum += self.data[i * self.cols + k] * other.data[k * other.cols + j];
        }
        new_mat.data[i * other.cols + j] = sum;
      }
    }

    Ok(new_mat)
  }

  pub fn vec_mul(&self, vec: &Vector) -> Result<Vector, Error> {
    if self.cols != vec.len() {
      return Err(Error::MatDimensionMismatch);
    }

    let mut res_mat = Vector::zeroes(self.rows);

    for i in 0..self.rows {
      let mut sum = scalar::zero();
      for k in 0..self.cols {
        sum += self.data[i * self.cols + k] * vec.get(k).unwrap();
      }
      res_mat.set(i, sum).unwrap();
    }

    Ok(res_mat)
  }

  pub fn add(&self, other: &Matrix) -> Result<Matrix, Error> {
    if self.rows != other.rows || self.cols != other.cols {
      return Err(Error::MatDimensionMismatch);
    }

    let mut res_mat = Matrix::zeros(self.rows, self.cols);

    res_mat.data = self.data.iter()
      .zip(&other.data)
      .map(|(&a, &b)| scalar::add(a, b))
      .collect::<Vec<Scalar>>();

    Ok(res_mat)
  }

  pub fn sub(&self, other: &Matrix) -> Result<Matrix, Error> {
    if self.rows != other.rows || self.cols != other.cols {
      return Err(Error::MatDimensionMismatch);
    }

    let mut res_mat = Matrix::zeros(self.rows, self.cols);

    res_mat.data = self.data.iter()
      .zip(&other.data)
      .map(|(&a, &b)| scalar::sub(a, b))
      .collect::<Vec<Scalar>>();

    Ok(res_mat)
  }
}
