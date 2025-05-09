// error.zig - Error definitions
// This file defines error codes for the
// parser
//
// Author: Fedi Nabli
// Date: 8 May 2025
// Last Modified: 9 May 2025

pub const ParserErrors = error{
    OK,
    ParseError,
    InvalidColCountPlus,
    InvalidColCountMinus,
};
