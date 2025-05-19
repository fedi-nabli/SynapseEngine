/// error.rs - Math Engine Error enum
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

#[derive(Debug)]
pub enum Error {
  IndexOutOfBounds,
  VectorDimensionMismatch,
  MatrixIndexOutOfBounds,
  MatDimensionMismatch,
}