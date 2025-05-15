// helper.zig - Helper functions
//
// This file defines helper functions for the
// SYNJ parser
//
// Author: Fedi Nabli
// Date: 15 May 2025
// Last Modified: 15 May 2025

pub fn is_digit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn is_alpha(c: u8) bool {
    return (c >= 'a' and c <= 'z') or
        (c >= 'A' and c <= 'Z') or
        c == '_';
}

pub fn is_keyword_char(c: u8) bool {
    return is_alpha(c) or is_digit(c);
}
