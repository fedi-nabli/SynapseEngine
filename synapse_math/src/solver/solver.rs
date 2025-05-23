/// solver/solver.rs - Math Engine Solver funcs
/// 
/// This file defines the solver functions
/// 
/// Author: Fedi Nabli
/// Date: 23 May 2025
/// Last Modified: 23 May 2025

use crate::error::Error;
use crate::linear_algebra::loss::Loss;
use crate::math::Scalar;
use crate::models::Model;
use crate::ffi::InternalInput;

use super::solver_utils;

pub struct Solver<M: Model> {
  pub model: M,
  pub input: InternalInput,
}

impl<M: Model> Solver<M> {
  /// Initialize solver and model parameters
  pub fn new(input: InternalInput) -> Self {
    let model = M::init(&input);
    Solver { model, input }
  }

  /// Run full training loop with batching, loss tracking and early stopping
  pub fn train(&mut self) -> Result<(), Error> {
    let mut best_loss: Option<Scalar> = None;
    let mut no_improve = 0;
    let patience = self.input.early_stop;

    for epoch in 1..=self.input.epochs {
      // Shuffle & batch training data
      let batches = solver_utils::batches(
        &self.input.train_x,
        &self.input.train_y,
        self.input.batch_size as usize,
      );

      for (batch_x, batch_y) in batches {
        // Forward pass: predictions
        let preds = self.model.predict(batch_x.clone())?;
        // Backward pass: gradient of loss
        let grad = M::LossFn::grad(&preds, &batch_y)?;
        // Update model parameters based on gradient
        self.model.update(&batch_x, &grad, self.input.learning_rate)?;
      }

      // Validation: compute loss on test set
      let val_preds = self.model.predict(self.input.test_x.clone())?;
      let val_loss = M::LossFn::loss(&val_preds, &self.input.test_y)?;
      println!("Epoch {}: validation loss = {}", epoch, val_loss);

      // Early stopping check
      if solver_utils::should_stop(best_loss, val_loss, patience, &mut no_improve) {
        println!("Early stopping triggered at epoch {}", epoch);
        break;
      }

      best_loss = Some(match best_loss {
        Some(prev) => prev.min(val_loss),
        None => val_loss,
      });
    }

    Ok(())
  }

  /// Evaluate the model on the test set, returning the final loss
  pub fn test(&self) -> Result<Scalar, Error> {
    let preds = self.model.predict(self.input.test_x.clone())?;
    M::LossFn::loss(&preds, &self.input.test_y)
  }
}
