// error.zig - Error definitions
// This file defines error codes for the
// JSON parser
//
// Author: Fedi Nabli
// Date: 12 May 2025
// Last Modified: 12 May 2025

pub const JsonParserErrors = error{
    ExpectedStartToken,
    ExpectedEndToken,
    MissingFields,
    StringParseError,
    IntParseError,
    FloatParseError,
    ArrayParseError,
    TrainlingComma,
    UnexpectedEndToken,
};
