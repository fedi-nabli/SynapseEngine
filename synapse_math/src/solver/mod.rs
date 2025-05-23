/// solver/mod.rs - Math Engine Solver module
/// 
/// This module exposes model solver functionalities
/// 
/// Author: Fedi Nabli
/// Date: 23 May 2025
/// Last Modified: 23 May 2025

pub mod solver;
pub mod solver_utils;

pub use solver::Solver;
pub use solver_utils::{shuffle_indices, batches, should_stop};
