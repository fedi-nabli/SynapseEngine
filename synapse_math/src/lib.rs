/// lib.rs - Math Engine Library main file
/// 
/// This file is the main file for the math engine static library
/// it contains some tests and important ffi functions
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

pub mod math;
pub mod error;

use core::ffi::c_ulonglong;

#[unsafe(no_mangle)]
pub extern "C" fn add_rust(left: c_ulonglong, right: c_ulonglong) -> c_ulonglong {
    left + right
}

#[cfg(test)]
mod tests {
    use crate::math::{scalar, Scalar, Vector, Matrix};

    use crate::error::Error;

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
}
