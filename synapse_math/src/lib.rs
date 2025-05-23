/// lib.rs - Math Engine Library main file
/// 
/// This file is the main file for the math engine static library
/// it contains some tests and important ffi functions
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 21 May 2025

pub mod ffi;
pub mod math;
pub mod rand;
pub mod stats;
pub mod error;
pub mod models;
pub mod solver;
pub mod linear_algebra;

use core::ffi::c_ulonglong;

#[unsafe(no_mangle)]
pub extern "C" fn add_rust(left: c_ulonglong, right: c_ulonglong) -> c_ulonglong {
    left + right
}

#[cfg(test)]
mod tests {
    use crate::linear_algebra::activation::Activation;
    use crate::linear_algebra::gradient::Optimizer;
    use crate::linear_algebra::loss::Loss;
    use crate::linear_algebra::{CrossEntropy, ReLU, Sigmoid, Tanh, MSE};
    use crate::math::{ln, scalar, Matrix, Scalar, Vector};
    use crate::linear_algebra::{SGD, Momentum, Adam};

    use crate::error::Error;
    use crate::models::Model;
    use crate::rand::Random;
    use crate::stats::{correlation, covariance, mean, normalize, std_dev, variance};

    use super::*;

    #[test]
    fn it_works() {
        let result = add_rust(2, 2);
        assert_eq!(result, 4);
    }

    #[test]
    fn scalar_test() {
        let s1: Scalar = scalar::one();
        let s2: Scalar = scalar::zero();

        assert_eq!(s1, 1.0);
        assert_eq!(s2, 0.0);

        assert_eq!(scalar::add(s1, s2), 1.0);
        assert_eq!(scalar::sub(s1, s2), 1.0);
        assert_eq!(scalar::mul(s1, s2), 0.0);
        assert_eq!(scalar::div(s2, s1), 0.0);

        assert_eq!(scalar::pow(s1, 2), 1.0);
        assert_eq!(scalar::powf(s1, 3.0), 1.0);

        assert_eq!(scalar::neg(s1), -1.0);

        assert_eq!(scalar::from_i32(32), 32.0);
        assert_eq!(scalar::from_usize(104), 104.0);
    }

    #[test]
    fn vector_test() {
        let mut zero_vec = Vector::zeroes(10);
        let one_vec = Vector::ones(12);

        assert_eq!(zero_vec.len(), 10);
        assert_eq!(one_vec.len(), 12);

        assert_eq!(zero_vec.sum(), 0.0);
        assert_eq!(one_vec.sum(), 12.0);

        match zero_vec.set(0, 9.8) {
            Err(_) => println!("Error"),
            Ok(()) => (),
        }
        assert_eq!(zero_vec.get(0).unwrap(), 9.8);

        let one_vec_2 = Vector::ones(12);
        let mut res_vec = one_vec.add(&one_vec_2).unwrap();
        assert_eq!(res_vec.sum(), 24.0);
        res_vec = res_vec.sub(&one_vec_2).unwrap();
        assert_eq!(res_vec.sum(), 12.0);

        res_vec = one_vec.scale(3.0);
        assert_eq!(res_vec.sum(), 36.0);

        let res = one_vec.dot(&one_vec_2).unwrap();
        assert_eq!(res, 12.0);
    }

    #[test]
    fn matrix_test() {
        let zero_mat = Matrix::zeros(2, 3);
        let one_mat = Matrix::ones(2, 3);

        assert_eq!(zero_mat.shape(), (2, 3));
        assert_eq!(one_mat.shape(), (2, 3));

        assert_eq!(zero_mat.data, vec![0.0; 6]);
        assert_eq!(one_mat.data, vec![1.0; 6]);

        let mut identity_mat = Matrix::identity(3);
        assert_eq!(identity_mat.data, vec![1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]);
        assert_eq!(identity_mat.shape(), (3, 3));

        assert_eq!(identity_mat.get(0, 0).unwrap(), 1.0);
        assert_eq!(identity_mat.get(1, 0).unwrap(), 0.0);

        identity_mat.set(0, 0, 3.6).unwrap();
        assert_eq!(identity_mat.get(0, 0).unwrap(), 3.6);

        let mut mat = Matrix::zeros(3, 3);
        mat.set(0, 0, 1.2).unwrap();
        mat.set(0, 1, 3.6).unwrap();
        mat.set(0, 2, 4.6).unwrap();
        mat.set(1, 0, 48.6).unwrap();
        mat.set(1, 1, 46.0).unwrap();
        mat.set(1, 2, 26.8).unwrap();
        mat.set(2, 0, 8.6).unwrap();
        mat.set(2, 1, 6.0).unwrap();
        mat.set(2, 2, 2.8).unwrap();

        assert_eq!(mat.data, vec![1.2, 3.6, 4.6, 48.6, 46.0, 26.8, 8.6, 6.0, 2.8]);
        let trans_mat = mat.transpose();
        assert_eq!(trans_mat.data, vec![1.2, 48.6, 8.6, 3.6, 46.0, 6.0, 4.6, 26.8, 2.8]);

        let mat1 = Matrix::ones(2, 3);
        let mut mat2 = Matrix::ones(3, 2);
        mat2.set(0, 1, 2.0).unwrap();
        mat2.set(1, 1, 2.0).unwrap();
        mat2.set(2, 1, 2.0).unwrap();

        let res_mat = mat1.mat_mul(&mat2).unwrap();

        assert_eq!(res_mat.data, vec![3.0, 6.0, 3.0, 6.0]);

        let mut mat3 = Matrix::zeros(2, 3);
        mat3.set(0, 0, 1.0).unwrap();
        mat3.set(0, 1, 2.0).unwrap();
        mat3.set(0, 2, 3.0).unwrap();
        mat3.set(1, 0, 4.0).unwrap();
        mat3.set(1, 1, 5.0).unwrap();
        mat3.set(1, 2, 6.0).unwrap();

        let mut vec = Vector::zeroes(3);
        vec.set(0, 1.0).unwrap();
        vec.set(1, 2.0).unwrap();
        vec.set(2, 3.0).unwrap();

        let result = mat3.vec_mul(&vec).unwrap();
        
        assert_eq!(result.get(0), Some(14.0));
        assert_eq!(result.get(1), Some(32.0)); 
    }

    #[test]
    fn test_matrix_add_sub() {
        let mut mat1 = Matrix::zeros(2, 2);
        mat1.set(0, 0, 1.0).unwrap();
        mat1.set(0, 1, 2.0).unwrap();
        mat1.set(1, 0, 3.0).unwrap();
        mat1.set(1, 1, 4.0).unwrap();

        let mut mat2 = Matrix::zeros(2, 2);
        mat2.set(0, 0, 5.0).unwrap();
        mat2.set(0, 1, 6.0).unwrap();
        mat2.set(1, 0, 7.0).unwrap();
        mat2.set(1, 1, 8.0).unwrap();

        // Test addition
        let sum = mat1.add(&mat2).unwrap();
        assert_eq!(sum.get(0, 0), Some(6.0));  // 1 + 5
        assert_eq!(sum.get(0, 1), Some(8.0));  // 2 + 6
        assert_eq!(sum.get(1, 0), Some(10.0)); // 3 + 7
        assert_eq!(sum.get(1, 1), Some(12.0)); // 4 + 8

        // Test subtraction
        let diff = mat1.sub(&mat2).unwrap();
        assert_eq!(diff.get(0, 0), Some(-4.0)); // 1 - 5
        assert_eq!(diff.get(0, 1), Some(-4.0)); // 2 - 6
        assert_eq!(diff.get(1, 0), Some(-4.0)); // 3 - 7
        assert_eq!(diff.get(1, 1), Some(-4.0)); // 4 - 8

        // Test dimension mismatch
        let mat3 = Matrix::zeros(2, 3);
        assert!(matches!(
            mat1.add(&mat3),
            Err(Error::MatDimensionMismatch)
        ));
        assert!(matches!(
            mat1.sub(&mat3),
            Err(Error::MatDimensionMismatch)
        ));
    }

    #[test]
    fn test_stats() {
        let mut vec1 = Vector::new(3);
        vec1.set(0, 1.0).unwrap();
        vec1.set(1, 2.0).unwrap();
        vec1.set(2, 3.0).unwrap();
        assert_eq!(mean(&vec1).unwrap(), 2.0);

        assert_eq!(variance(&vec1, 0).unwrap(), 2.0/3.0);
        assert_eq!(variance(&vec1, 1).unwrap(), 1.0);

        let normalized = normalize(&vec1, 0).unwrap();
        assert!((normalized.get(0).unwrap() + 1.224745).abs() < 1e-6);
        assert!((normalized.get(1).unwrap()).abs() < 1e-6);
        assert!((normalized.get(2).unwrap() - 1.224745).abs() < 1e-6);

        let mut x = Vector::new(3);
        let mut y = Vector::new(3);
        x.set(0, 1.0).unwrap();
        x.set(1, 2.0).unwrap();
        x.set(2, 3.0).unwrap();
        y.set(0, 2.0).unwrap();
        y.set(1, 4.0).unwrap();
        y.set(2, 6.0).unwrap();
        assert_eq!(correlation(&x, &y, 0).unwrap(), 1.0);

        let std_pop = std_dev(variance(&vec1, 0).unwrap());
        let std_sample = std_dev(variance(&vec1, 1).unwrap());
        assert!((std_pop - 0.816497).abs() < 1e-6);  // sqrt(2/3)
        assert_eq!(std_sample, 1.0);

        let cov_pop = covariance(&x, &y, 0).unwrap();
        let cov_sample = covariance(&x, &y, 1).unwrap();
        assert!((cov_pop - 1.333333333333333).abs() < 1e-6); // population covatiance
        assert_eq!(cov_sample, 2.0);  // sample covariance

        // Test covariance error cases
        let mut z = Vector::new(2);  // different length vector
        z.set(0, 1.0).unwrap();
        z.set(1, 2.0).unwrap();
        assert!(matches!(
            covariance(&x, &z, 0),
            Err(Error::InsufficientData)
        ));
    }

    #[test]
    fn test_loss_functions() {
        // Test MSE
        let mut pred = Vector::new(3);
        let mut target = Vector::new(3);
        
        pred.set(0, 1.0).unwrap();
        pred.set(1, 2.0).unwrap();
        pred.set(2, 3.0).unwrap();
        
        target.set(0, 2.0).unwrap();
        target.set(1, 4.0).unwrap();
        target.set(2, 6.0).unwrap();
        
        // MSE = (1/3)[(1-2)² + (2-4)² + (3-6)²] = (1 + 4 + 9)/3 = 14/3
        assert!((MSE::loss(&pred, &target).unwrap() - 14.0/3.0).abs() < 1e-6);
        
        let grad = MSE::grad(&pred, &target).unwrap();
        // Gradient = (2/3)[(-1, -2, -3)]
        assert!((grad.get(0).unwrap() + 2.0/3.0).abs() < 1e-6);
        assert!((grad.get(1).unwrap() + 4.0/3.0).abs() < 1e-6);
        assert!((grad.get(2).unwrap() + 2.0).abs() < 1e-6);

        // Test Cross Entropy
        let mut pred_ce = Vector::new(2);
        let mut target_ce = Vector::new(2);
        
        pred_ce.set(0, 0.8).unwrap();
        pred_ce.set(1, 0.2).unwrap();
        
        target_ce.set(0, 1.0).unwrap();
        target_ce.set(1, 0.0).unwrap();
        
        // CE = -(1/2)(1*ln(0.8) + 0*ln(0.2)) = -ln(0.8)/2
        let expected = -ln(0.8)/2.0;
        assert!((CrossEntropy::loss(&pred_ce, &target_ce).unwrap() - expected).abs() < 1e-6);
        
        let grad_ce = CrossEntropy::grad(&pred_ce, &target_ce).unwrap();
        // Gradient = -(1/2)[(1/0.8, 0/0.2)]
        assert!((grad_ce.get(0).unwrap() + 0.625).abs() < 1e-6);
        assert!((grad_ce.get(1).unwrap()).abs() < 1e-6);

        // Test Error Cases
        let v1 = Vector::new(2);
        let v2 = Vector::new(3);
        
        // Test dimension mismatch
        assert!(matches!(MSE::loss(&v1, &v2), Err(Error::VectorDimensionMismatch)));
        assert!(matches!(MSE::grad(&v1, &v2), Err(Error::VectorDimensionMismatch)));
        assert!(matches!(CrossEntropy::loss(&v1, &v2), Err(Error::VectorDimensionMismatch)));
        assert!(matches!(CrossEntropy::grad(&v1, &v2), Err(Error::VectorDimensionMismatch)));

        // Test empty vectors
        let empty_vec = Vector::new(0);
        assert!(matches!(MSE::loss(&empty_vec, &empty_vec), Err(Error::VectorDimensionMismatch)));
        assert!(matches!(MSE::grad(&empty_vec, &empty_vec), Err(Error::VectorDimensionMismatch)));

        // Test invalid inputs for cross entropy (predictions <= 0)
        let mut invalid_pred = Vector::new(2);
        invalid_pred.set(0, 0.0).unwrap();
        invalid_pred.set(1, 1.0).unwrap();
        assert!(matches!(CrossEntropy::loss(&invalid_pred, &target_ce), Err(Error::InsufficientData)));
        assert!(matches!(CrossEntropy::grad(&invalid_pred, &target_ce), Err(Error::InsufficientData)));
    }

    #[test]
    fn test_activation_functions() {
        // Test ReLU
        assert_eq!(ReLU::forward(-1.0), 0.0);
        assert_eq!(ReLU::forward(0.0), 0.0);
        assert_eq!(ReLU::forward(2.0), 2.0);
        
        assert_eq!(ReLU::backward(-1.0), 0.0);
        assert_eq!(ReLU::backward(0.0), 0.0);
        assert_eq!(ReLU::backward(2.0), 1.0);

        // Test Sigmoid
        assert!((Sigmoid::forward(0.0) - 0.5).abs() < 1e-6);
        assert!((Sigmoid::forward(2.0) - 0.880797).abs() < 1e-6);
        assert!((Sigmoid::forward(-2.0) - 0.119203).abs() < 1e-6);

        assert!((Sigmoid::backward(0.0) - 0.25).abs() < 1e-6);
        assert!((Sigmoid::backward(2.0) - 0.104994).abs() < 1e-6);
        assert!((Sigmoid::backward(-2.0) - 0.104994).abs() < 1e-6);

        // Test Tanh
        assert_eq!(Tanh::forward(0.0), 0.0);
        assert!((Tanh::forward(1.0) - 0.761594).abs() < 1e-6);
        assert!((Tanh::forward(-1.0) + 0.761594).abs() < 1e-6);

        assert_eq!(Tanh::backward(0.0), 1.0);
        assert!((Tanh::backward(1.0) - 0.419974).abs() < 1e-6);
        assert!((Tanh::backward(-1.0) - 0.419974).abs() < 1e-6);

        // Test edge cases
        assert!((Sigmoid::forward(10.0) - 1.0).abs() < 1e-4); // Very large input
        assert!((Sigmoid::forward(-10.0)).abs() < 1e-4);      // Very small input
        assert!((Tanh::forward(10.0) - 1.0).abs() < 1e-4);   // Very large input
        assert!((Tanh::forward(-10.0) + 1.0).abs() < 1e-4);  // Very small input
    }

    #[test]
    fn test_optimizers() {
        // Test function: f(x) = x^2, gradient = 2x
        let mut params = Vector::new(1);
        params.set(0, 2.0).unwrap();  // Start at x = 2

        // Test SGD
        {
            let mut sgd = SGD { lr: 0.1 };
            let mut p = params.clone();
            
            for _ in 0..10 {
                let mut grad = Vector::new(1);
                grad.set(0, 2.0 * p.get(0).unwrap()).unwrap();
                sgd.update(&mut p, &grad).unwrap();
            }
            
            assert!(p.get(0).unwrap().abs() < 1.0);
        }

        // Test Momentum
        {
            let mut momentum = Momentum {
                lr: 0.1,
                momentum: 0.9,
                velocity: Vector::zeroes(1),
            };
            let mut p = params.clone();
            
            for _ in 0..10 {
                let mut grad = Vector::new(1);
                grad.set(0, 2.0 * p.get(0).unwrap()).unwrap();
                momentum.update(&mut p, &grad).unwrap();
            }
            
            assert!(p.get(0).unwrap().abs() < 0.8);
        }

        // Test Adam
        {
            let mut adam = Adam {
                lr: 0.1,
                beta1: 0.9,
                beta2: 0.999,
                eps: 1e-8,
                m: Vector::zeroes(1),
                v: Vector::zeroes(1),
                t: 0,
            };
            let mut p = params.clone();
            
            for _ in 0..20 {
                let mut grad = Vector::new(1);
                grad.set(0, 2.0 * p.get(0).unwrap()).unwrap();
                adam.update(&mut p, &grad).unwrap();
            }
            
            assert!(p.get(0).unwrap().abs() < 0.5);
        }
    }

    #[test]
    fn test_random_generation() {
        let mut rng = Random::new(Some(42)); // Use seed for deterministic tests
        
        // Test uniform scalar
        let u = rng.uniform_scalar(0.0, 1.0);
        assert!(u >= 0.0 && u <= 1.0);

        // Test normal scalar
        let n = rng.normal_scalar(0.0, 1.0);
        assert!(!n.is_nan() && !n.is_infinite());

        // Test vector generation
        let v = rng.uniform_vector(10, 0.0, 1.0);
        assert_eq!(v.len(), 10);
        
        // Test matrix generation
        let m = rng.normal_matrix(2, 3, 0.0, 1.0);
        assert_eq!(m.shape(), (2, 3));
    }

    #[test]
    fn linear_regression_celsius_fahrenheit() -> Result<(), crate::error::Error> {
        use crate::ffi::{InternalInput, ModelType};
        use crate::math::{Matrix, Vector};
        use crate::models::linear_regression::LinearRegression;
        use crate::math::Scalar;
        use crate::linear_algebra::MSE;

        // 30+ points mapping Celsius → Fahrenheit
        let celsius_values: Vec<Scalar> = vec![
            -50.0, -40.0, -30.0, -20.0, -10.0, -9.0, -8.0, -7.0,
            -6.0, -5.0, -4.0, -3.0, -2.0, -1.0,  0.0,  1.0,
            2.0,   3.0,   4.0,   5.0,   6.0,   7.0,   8.0,   9.0,
            10.0,  20.0,  30.0,  40.0,  50.0,  60.0,
        ];
        let fahrenheit_values: Vec<Scalar> = vec![
            -58.0, -40.0, -22.0,  -4.0,  14.0,  15.8,  17.6,  19.4,
            21.2,  23.0,  24.8,  26.6,  28.4,  30.2,  32.0,  33.8,
            35.6,  37.4,  39.2,  41.0,  42.8,  44.6,  46.4,  48.2,
            50.0,  68.0,  86.0, 104.0, 122.0, 140.0,
        ];

        // compute means
        let count = celsius_values.len() as Scalar;
        let mean_celsius = celsius_values.iter().sum::<Scalar>() / count;
        let mean_fahrenheit = fahrenheit_values.iter().sum::<Scalar>() / count;

        // compute standard deviations
        let variance_celsius = celsius_values
            .iter()
            .map(|&x| (x - mean_celsius).powi(2))
            .sum::<Scalar>() / count;
        let std_celsius = variance_celsius.sqrt();

        let variance_fahrenheit = fahrenheit_values
            .iter()
            .map(|&y| (y - mean_fahrenheit).powi(2))
            .sum::<Scalar>() / count;
        let std_fahrenheit = variance_fahrenheit.sqrt();

        // normalize inputs and outputs
        let normalized_celsius: Vec<Scalar> = celsius_values
            .iter()
            .map(|&x| (x - mean_celsius) / std_celsius)
            .collect();
        let normalized_fahrenheit: Vec<Scalar> = fahrenheit_values
            .iter()
            .map(|&y| (y - mean_fahrenheit) / std_fahrenheit)
            .collect();

        // build training matrices/vectors
        let train_x = Matrix {
            rows: normalized_celsius.len(),
            cols: 1,
            data: normalized_celsius.clone(),
        };
        let train_y = Vector {
            data: normalized_fahrenheit.clone(),
        };
        let test_x = train_x.clone();
        let test_y = train_y.clone();

        // set up internal input
        let input = InternalInput {
            epochs:        1_000,
            batch_size:    normalized_celsius.len() as u32,
            early_stop:    1_000,
            learning_rate: 0.1,
            model_type:    ModelType::LinearRegression,
            train_x,
            train_y,
            test_x,
            test_y,
        };

        // train the model
        let mut model = LinearRegression::init(&input);
        model.train(&input)?;

        // Extract and un-scale the learned weight & bias ---
        let weight_normalized = model.weights.get(0).unwrap();
        let bias_normalized = model.bias;
        let learned_weight = weight_normalized * (std_fahrenheit / std_celsius);
        let learned_bias = bias_normalized * std_fahrenheit
            + mean_fahrenheit
            - learned_weight * mean_celsius;

        // slope should be ≈1.8, intercept ≈32.0
        assert!(
            (learned_weight - 1.8).abs() < 1e-2,
            "slope ≈ 1.8, got {}",
            learned_weight
        );
        assert!(
            (learned_bias - 32.0).abs() < 5e-1,
            "intercept ≈ 32.0, got {}",
            learned_bias
        );

        // predict on normalized scale, then un-scale
        let predictions_normalized = model.predict(input.test_x)?;
        let unscaled_predictions: Vec<Scalar> = predictions_normalized
            .data
            .iter()
            .map(|&y_n| y_n * std_fahrenheit + mean_fahrenheit)
            .collect();
        let predictions_vector = Vector {
            data: unscaled_predictions,
        };

        // compute final MSE on original Fahrenheit values
        let final_mse = MSE::loss(
            &predictions_vector,
            &Vector { data: fahrenheit_values.clone() },
        )?;
        assert!(final_mse < 1e-1, "final MSE too large: {}", final_mse);

        Ok(())
    }

    #[test]
    fn linear_regression_two_features() -> Result<(), crate::error::Error> {
        use crate::ffi::{InternalInput, ModelType};
        use crate::math::{Matrix, Vector};
        use crate::models::linear_regression::LinearRegression;
        use crate::math::Scalar;
        use crate::linear_algebra::MSE;

        // y = 2·x1 + 3·x2 + 1 over 5 points
        let x1 = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        let x2 = vec![5.0, 4.0, 3.0, 2.0, 1.0];
        let mut data = Vec::with_capacity(x1.len() * 2);
        for i in 0..x1.len() {
            data.push(x1[i]);
            data.push(x2[i]);
        }

        let y: Vec<Scalar> = x1.iter()
            .zip(x2.iter())
            .map(|(&a, &b)| 2.0*a + 3.0*b + 1.0)
            .collect();

        let n = x1.len();
        let train_x = Matrix { rows: n, cols: 2, data: data.clone() };
        let train_y = Vector { data: y.clone() };
        let test_x  = train_x.clone();
        let test_y  = train_y.clone();

        let input = InternalInput {
            epochs:        1_000,
            batch_size:    n as u32,
            early_stop:    1_000,
            learning_rate: 1e-2,
            model_type:    ModelType::LinearRegression,
            train_x,
            train_y,
            test_x,
            test_y,
        };

        let mut model = LinearRegression::init(&input);
        model.train(&input)?;

        let w1 = model.weights.get(0).unwrap();
        let w2 = model.weights.get(1).unwrap();
        let b  = model.bias;

        // relax to ±0.05 on slopes
        assert!((w1 - 2.0).abs() < 5e-2, "w1 ≈ 2.0, got {}", w1);
        assert!((w2 - 3.0).abs() < 5e-2, "w2 ≈ 3.0, got {}", w2);
        assert!((b  - 1.0).abs() < 2e-1, "b  ≈ 1.0, got {}", b);

        let preds = model.predict(input.test_x.clone())?;
        let mse   = MSE::loss(&preds, &input.test_y)?;
        assert!(mse < 1e-2, "final MSE too large: {}", mse);

        Ok(())
    }
}
