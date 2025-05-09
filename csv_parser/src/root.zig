const std = @import("std");
const testing = std.testing;

const CSV = @import("csv.zig").CSV;
const Header = @import("csv.zig").Header;
const Data = @import("csv.zig").Data;
const Row = @import("csv.zig").Row;
const Number = @import("csv.zig").Number;

const ParserErrors = @import("error.zig").ParserErrors;

const parser = @import("parser.zig");
const ParserResponse = parser.ParserResponse;

// Global static allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// A reference to the allocator interface
const global_allocator = gpa.allocator();

pub export fn csv_parser_parse(
    buffer_ptr: [*]const u8,
    buffer_len: usize,
    sep: u8,
) ?*CSV {
    const buf = buffer_ptr[0..buffer_len];
    const csv_ptr = global_allocator.create(CSV) catch return null;
    csv_ptr.* = parser.csv_parser_init(global_allocator, sep);

    parser.parser_parse_body(global_allocator, csv_ptr, buf) catch |err| {
        std.debug.print("Error in parser_parse_body: {}\n", .{err});
        global_allocator.destroy(csv_ptr);
        return null;
    };

    const res: ParserResponse = parser.parser_validate_data_length(csv_ptr);
    if (res.valid == false) {
        const stdout = std.io.getStdOut().writer();
        if (res.perror == ParserErrors.InvalidColCountPlus) {
            stdout.print("CSV Error: Too many columns for row {?d}, row_col_num: {?d}, should be: {d}\n", .{ res.row, res.length, csv_ptr.header.num_cols }) catch return null;
        }

        if (res.perror == ParserErrors.InvalidColCountMinus) {
            stdout.print("CSV Error: Too few columns for row {?d}, row_col_num: {?d}, should be: {d}\n", .{ res.row, res.length, csv_ptr.header.num_cols }) catch return null;
        }

        return null;
    }

    return csv_ptr;
}

pub export fn csv_parser_free(csv: *CSV) void {
    // Free terminator
    if (csv.terminator != null) {
        global_allocator.free(std.mem.sliceTo(csv.terminator.?, 0));
    }

    // Free header column
    if (csv.header.num_cols > 0 and csv.header.col_names != null) {
        const col_names = csv.header.col_names.?;

        // Free each column name string
        var i: usize = 0;
        while (i < csv.header.num_cols) : (i += 1) {
            const str = col_names[i];
            global_allocator.free(std.mem.sliceTo(str, 0));
        }

        // Free the array of pointers itself
        global_allocator.free(col_names[0..csv.header.num_cols]);
    }

    // Free each row's values
    if (csv.data.num_rows > 0 and csv.data.rows.len > 0) {
        for (csv.data.rows[0..csv.data.num_rows]) |row| {
            if (row.values.len > 0) {
                global_allocator.free(row.values);
            }
        }

        global_allocator.free(csv.data.rows);
    }

    // Free the csv struct
    global_allocator.destroy(csv);
}

pub fn csv_parser_deinit() bool {
    //Check for leaks and clean up the allocator
    return gpa.deinit();
}

test "basic add functionality" {}
