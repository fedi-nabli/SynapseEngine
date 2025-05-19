/// math/elem.rs - Math Engine Element wise module
/// 
/// This module exposes core math Scalar
/// inline functions
/// 
/// Author: Fedi Nabli
/// Date: 19 May 2025
/// Last Modified: 19 May 2025

use super::Scalar;

#[inline]
pub fn exp(x: Scalar) -> Scalar { x.exp() }

#[inline]
pub fn ln(x: Scalar) -> Scalar { x.ln() }

#[inline]
pub fn sqrt(x: Scalar) -> Scalar { x.sqrt() }

#[inline]
pub fn abs(x: Scalar) -> Scalar { x.abs() }

#[inline]
pub fn cos(x: Scalar) -> Scalar { x.cos() }

#[inline]
pub fn sin(x: Scalar) -> Scalar { x.sin() }

#[inline]
pub fn tan(x: Scalar) -> Scalar { x.tan() }

#[inline]
pub fn cosh(x: Scalar) -> Scalar { x.cosh() }

#[inline]
pub fn sinh(x: Scalar) -> Scalar { x.sinh() }

#[inline]
pub fn tanh(x: Scalar) -> Scalar { x.tanh() }
