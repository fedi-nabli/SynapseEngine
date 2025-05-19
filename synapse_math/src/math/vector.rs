/// vector.rs - Math Engine Vector type
/// 
/// This file defines the Vector structure
/// and exposes important functionalities for
/// the data type
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

use super::{scalar, Scalar};

use crate::error::Error;

#[derive(Debug)]
pub struct Vector {
  pub data: Vec<Scalar>,
}

impl Vector {
  pub fn new(len: usize) -> Vector {
    Vector {
      data: vec![scalar::zero(); len]
    }
  }

  pub fn zeroes(len: usize) -> Vector {
    Vector {
      data: vec![0.0; len]
    }
  }

  pub fn ones(len: usize) -> Vector {
    Vector {
      data: vec![1.0; len]
    }
  }

  pub fn len(&self) -> usize {
    self.data.len()
  }

  pub fn is_empty(&self) -> bool {
    self.data.is_empty()
  }

  pub fn get(&self, idx: usize) -> Option<Scalar> {
    match self.data.get(idx) {
      Some(&value) => Some(value),
      None => None,
    }
  }

  pub fn set(&mut self, idx: usize, s: Scalar) -> Result<(), Error> {
    if idx >= self.len() {
      return Err(Error::IndexOutOfBounds);
    }

    self.data[idx] = s;
    Ok(())
  }

  pub fn dot(&self, other: &Vector) -> Result<Scalar, Error> {
    if self.len() != other.len() {
      return Err(Error::VectorDimensionMismatch);
    }

    Ok(self.data.iter()
      .zip(&other.data)
      .map(|(&a, &b)| scalar::mul(a, b))
      .sum())
  }

  pub fn scale(&self, s: Scalar) -> Vector {

    let len = self.len();

    let mut res_vec = Vector::zeroes(len);

    for idx in 0..len {
      res_vec.data[idx] = scalar::mul(self.get(idx).unwrap(), s);
    }

    res_vec
  }

  pub fn add(&self, rhs: &Vector) -> Result<Vector, Error> {
    if self.len() != rhs.len() {
      return Err(Error::VectorDimensionMismatch);
    }

    let mut res_vec = Vector::zeroes(self.len());

    for idx in 0..self.len() {
      let a = self.get(idx).unwrap();
      let b = rhs.get(idx).unwrap();
      let sum = scalar::add(a, b);
      res_vec.set(idx, sum)?;
    }

    Ok(res_vec)
  }

  pub fn sub(&self, rhs: &Vector) -> Result<Vector, Error> {
    if self.len() != rhs.len() {
      return Err(Error::VectorDimensionMismatch);
    }

    let mut res_vec = Vector::zeroes(self.len());

    for idx in 0..self.len() {
      let a = self.get(idx).unwrap();
      let b = rhs.get(idx).unwrap();
      let sum = scalar::sub(a, b);
      res_vec.set(idx, sum)?;
    }

    Ok(res_vec)
  }

  pub fn sum(&self) -> Scalar {
    let mut sum = scalar::zero();
    for idx in 0..self.len() {
      sum += self.get(idx).unwrap();
    }

    return sum;
  }

  // TODO: map function
  // TODO: vector mean and variance
}
