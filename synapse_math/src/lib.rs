#![allow(non_snake_case)]

use core::ffi::c_ulonglong;

#[unsafe(no_mangle)]
pub extern "C" fn add_rust(left: c_ulonglong, right: c_ulonglong) -> c_ulonglong {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add_rust(2, 2);
        assert_eq!(result, 4);
    }
}
