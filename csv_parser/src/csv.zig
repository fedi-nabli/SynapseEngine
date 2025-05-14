// csv.zig - CSV Structure definitions
// This file defines structures, enums and unions
// for the CSV structure to be parsed
//
// Author: Fedi Nabli
// Date: 8 May 2025
// Last Modified: 9 May 2025

pub const DataType = enum {
    INTEGER,
    FLOAT,
};

pub const NumValue = union {
    int_val: i64,
    float_val: f64,
};

pub const Number = struct {
    value: NumValue,
    dtype: DataType,
};

pub const Row = struct {
    num_cols: usize,
    values: []Number,
};

pub const Data = struct {
    num_rows: usize,
    rows: []Row,
};

pub const Header = struct {
    col_names: ?[*][*:0]u8,
    num_cols: usize,
};

pub const CSV = struct {
    seperator: u8,
    terminator: ?[*:0]const u8,
    header: Header,
    data: Data,

    pub fn init_default() CSV {
        return CSV{
            .seperator = ',',
            .terminator = null,
            .header = Header{
                .col_names = null,
                .num_cols = 0,
            },
            .data = Data{
                .num_rows = 0,
                .rows = &[_]Row{},
            },
        };
    }
};
