// error.zig - Error definitions
//
// This file defines error codes for the
// SYNJ parser
//
// Author: Fedi Nabli
// Date: 15 May 2025
// Last Modified: 15 May 2025

pub const TokenizerErrors = error{
    UnexpectedCharacter,
    UnterminatedString,
    InvalidNumber,
    InvalidKeyword,
    OutOfMemory,
};
