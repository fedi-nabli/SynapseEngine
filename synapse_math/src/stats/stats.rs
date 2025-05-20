/// stats/stats.rs - Math Engine Statistics funcs
/// 
/// Author: Fedi Nabli
/// Date: 20 May 2025
/// Last Modified: 20 May 2025

use crate::math::{Scalar, Vector, sqrt};
use crate::error::Error;

/// Arithmetic mean (average)
pub fn mean(vec: &Vector) -> Result<Scalar, Error> {
  let len = vec.len();
  if len == 0 {
    return Err(Error::InsufficientData);
  }

  Ok(vec.sum() / (len as Scalar))
}

/// Variance = SUM(Xi - mean)2 / (n - ddof)
/// ddof = 0: population variance
/// ddof = 1: sample variance
pub fn variance(vec: &Vector, ddof: usize) -> Result<Scalar, Error> {
  let len = vec.len();
  if len == 0 || ddof >= len {
    return Err(Error::InsufficientData);
  }

  let avg = mean(vec)?;
  let sum_sq = vec.data.iter()
    .map(|&x| {
      let d = x - avg;
      d * d
    })
    .sum::<Scalar>();

  Ok(sum_sq / ((len - ddof) as Scalar))
}

/// Standard Deviation
/// std = sqrt(variance)
pub fn std_dev(var: Scalar) -> Scalar {
  return sqrt(var);
}

/// Z-score normalization (Xi - mean) / std_dev
pub fn normalize(vec: &Vector, ddof: usize) -> Result<Vector, Error> {
  let avg = mean(vec)?;
  let sd = std_dev(variance(vec, ddof)?);
  let data = vec.data.iter()
    .map(|&x| (x - avg) / sd)
    .collect();

  Ok(Vector { data: data })
}

/// Covariance between 2 datasets
/// SUM([(Xi - meanX)(Yi - meanY)]) / (n - ddof)
pub fn covariance(x: &Vector, y: &Vector, ddof: usize) -> Result<Scalar, Error> {
  let xlen = x.len();
  if xlen != y.len() || xlen == 0 || ddof >= xlen {
    return Err(Error::InsufficientData);
  }

  let avg_x = mean(x)?;
  let avg_y = mean(y)?;
  let cov = x.data.iter()
    .zip(&y.data)
    .map(|(&a, &b)| (a - avg_x) * (b - avg_y))
    .sum::<Scalar>() / ((xlen - ddof) as Scalar); 

  Ok(cov)
}

/// Pearson corroleation coefficient
/// covariance(X, Y) / (std_dev(X) * std_dev(Y))
pub fn correlation(x: &Vector, y: &Vector, ddof: usize) -> Result<Scalar, Error> {
  let cov = covariance(x, y, ddof)?;
  let var_x = variance(x, ddof)?;
  let var_y = variance(y, ddof)?;
  Ok(cov / (std_dev(var_x) * std_dev(var_y)))
}
