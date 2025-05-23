/// solver/solver_utils.rs - Math Engine Solver Utils Structs
/// 
/// This file defines different functions for the Solver module
/// inclusing shuffling, early stopping and batch chunking
/// 
/// Author: Fedi Nabli
/// Date: 23 May 2025
/// Last Modified: 23 May 2025

use rand::seq::SliceRandom;

use crate::math::{Matrix, Scalar, Vector};

/// Return a random permutation
pub fn shuffle_indices(n: usize) -> Vec<usize> {
  let mut idx: Vec<usize> = (0..n).collect();
  idx.shuffle(&mut rand::rng());
  idx
}

/// Split X and Y into mini batches of size `batch_size`
pub fn batches(x: &Matrix, y: &Vector, batch_size: usize) -> Vec<(Matrix, Vector)> {
  let n = x.rows;
  let idx = shuffle_indices(n);

  idx.chunks(batch_size)
    .map(|chunk| {
      let mut bx = Vec::with_capacity(chunk.len() * x.cols);
      let mut by = Vec::with_capacity(chunk.len());

      for &i in chunk {
        let start = i * x.cols;
        let end = start + x.cols;
        bx.extend_from_slice(&x.data[start..end]);
        by.push(y.data[i]);
      }

      (
        Matrix { rows: chunk.len(), cols: x.cols, data: bx },
        Vector { data: by },
      )
    })
    .collect()
}

/// Return true if we've gone `patience` epochs without improvement
pub fn should_stop(
  best_so_far: Option<Scalar>,
  current: Scalar,
  patience: u32,
  no_improve_counter: &mut u32,
) -> bool {
  if let Some(best) = best_so_far {
    if current < best {
      *no_improve_counter = 0;
      false
    } else {
      *no_improve_counter += 1;
      *no_improve_counter >= patience
    }
  } else {
    // First epoch, nothing to compare yet
    false
  }
}
