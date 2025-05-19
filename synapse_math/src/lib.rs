/// lib.rs - Math Engine Library main file
/// 
/// This file is the main file for the math engine static library
/// it contains some tests and important ffi functions
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

pub mod math;

use core::ffi::c_ulonglong;

#[unsafe(no_mangle)]
pub extern "C" fn add_rust(left: c_ulonglong, right: c_ulonglong) -> c_ulonglong {
    left + right
}

#[cfg(test)]
mod tests {
    use crate::math::{scalar, Scalar};

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
}
