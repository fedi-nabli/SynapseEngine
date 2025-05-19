/// scalar.rs - Math Engine Scalar type
/// 
/// Scalar is just a wrapper around f64 with helper
/// functions for the type
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

pub type Scalar = f64;

#[inline]
pub const fn zero() -> Scalar { 0.0 }

#[inline]
pub const fn one() -> Scalar { 1.0 }

#[inline]
pub const fn from_i32(n: i32) -> Scalar { n as Scalar }

#[inline]
pub const fn from_usize(n: usize) -> Scalar { n as Scalar }

#[inline]
pub fn add(lhs: Scalar, rhs: Scalar) -> Scalar { lhs + rhs }

#[inline]
pub fn sub(lhs: Scalar, rhs: Scalar) -> Scalar { lhs - rhs }

#[inline]
pub fn mul(lhs: Scalar, rhs: Scalar) -> Scalar { lhs * rhs }

#[inline]
pub fn div(lhs: Scalar, rhs: Scalar) -> Scalar { lhs / rhs }

#[inline]
pub fn pow(s: Scalar, n: i32) -> Scalar { s.powi(n) }

#[inline]
pub fn powf(s1: Scalar, s2: Scalar) -> Scalar { s1.powf(s2) }

#[inline]
pub fn neg(s: Scalar) -> Scalar { -s }
