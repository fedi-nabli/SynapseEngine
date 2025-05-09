// parser.zig - CSV parser functions
// This file implements different functions to
// parse the CSV file
//
// Author: Fedi Nabli
// Date: 8 May 2025
// Last Modified: 9 May 2025

const std = @import("std");

const csv_structs = @import("csv.zig");
const CSV = csv_structs.CSV;
const Row = csv_structs.Row;
const Number = csv_structs.Number;

const ParserErrors = @import("error.zig").ParserErrors;

pub const ParserResponse = struct {
    valid: bool,
    row: ?usize,
    length: ?usize,
    perror: ParserErrors,
};

pub fn csv_parser_init(allocator: std.mem.Allocator, sep: u8) CSV {
    var csv = CSV.init_default();
    csv.seperator = if (sep != 0) sep else ',';
    const term = allocator.dupeZ(u8, "\n") catch return csv;
    csv.terminator = term;
    return csv;
}

fn split_line(
    allocator: std.mem.Allocator,
    line: []const u8,
    sep: u8,
) ![][]const u8 {
    var parts = std.ArrayList([]const u8).init(allocator);
    var start: usize = 0;
    var in_quotes = false;
    for (line, 0..) |c, idx| {
        if (c == '"') {
            in_quotes = !in_quotes;
        } else if (c == sep and !in_quotes) {
            if (idx == start) {
                try parts.append("");
            } else {
                try parts.append(line[start..idx]);
            }
            start = idx + 1;
        }
    }

    if (start < line.len) {
        try parts.append(line[start..]);
    }

    return parts.toOwnedSlice();
}

fn parser_parse_number(field: []const u8) !Number {
    const trimmed = std.mem.trim(u8, field, " ");
    if (trimmed.len == 0 or std.mem.eql(u8, field, "null") or std.mem.eql(u8, field, "NULL")) {
        return Number{ .value = .{ .int_val = 0 }, .dtype = .INTEGER };
    }

    const i_res = std.fmt.parseInt(i64, field, 10) catch null;
    if (i_res) |i| {
        return Number{ .value = .{ .int_val = i }, .dtype = .INTEGER };
    }

    const f_res = std.fmt.parseFloat(f64, field) catch null;
    if (f_res) |f| {
        return Number{ .value = .{ .float_val = f }, .dtype = .FLOAT };
    }

    return ParserErrors.ParseError;
}

fn parser_parse_header(
    allocator: std.mem.Allocator,
    csv: *CSV,
    line: []const u8,
) !void {
    const fields = try split_line(allocator, line, csv.seperator);

    var c_strings = try allocator.alloc([*:0]u8, fields.len);
    for (fields, 0..) |field, i| {
        c_strings[i] = try allocator.dupeZ(u8, field);
    }

    csv.header.col_names = c_strings.ptr;
    csv.header.num_cols = c_strings.len;
}

fn parser_parse_row(
    allocator: std.mem.Allocator,
    csv: *CSV,
    line: []const u8,
) !Row {
    const fields = try split_line(allocator, line, csv.seperator);
    defer allocator.free(fields);

    var vals = std.ArrayList(Number).init(allocator);
    for (fields) |f| {
        const num = parser_parse_number(f) catch |err| {
            const stdout = std.io.getStdOut().writer();
            stdout.print("Error parsing CSV, expected only numerical data, instead got: {s}\n", .{f}) catch {};
            return err;
        };
        try vals.append(num);
    }

    return Row{ .values = try vals.toOwnedSlice(), .num_cols = fields.len };
}

pub fn parser_parse_body(
    allocator: std.mem.Allocator,
    csv: *CSV,
    buffer: []const u8,
) !void {
    var row_list = std.ArrayList(Row).init(allocator);

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var start_idx: usize = 0;
    for (buffer, 0..) |c, i| {
        if (c == '\n') {
            if (i > start_idx) {
                const line = buffer[start_idx..i];
                try lines.append(line);
            } else {
                // Handle empty line
                try lines.append("");
            }
            start_idx = i + 1;
        }
    }

    // Handle if last line if it doesn't end with a newline
    if (start_idx < buffer.len) {
        try lines.append(buffer[start_idx..]);
    }

    for (lines.items, 0..) |line, i| {
        if (line.len == 0) {
            const stdout = std.io.getStdOut().writer();
            stdout.print("Skipping empty line {d}\n", .{i}) catch {};
            continue;
        }

        if (i == 0) {
            try parser_parse_header(allocator, csv, line);
        } else {
            const row = try parser_parse_row(allocator, csv, line);
            try row_list.append(row);
        }
    }

    csv.data.num_rows = row_list.items.len;
    csv.data.rows = try row_list.toOwnedSlice();
}

pub fn parser_validate_data_length(csv: *CSV) ParserResponse {
    const num_cols = csv.header.num_cols;
    var res: ParserResponse = .{
        .valid = true,
        .row = null,
        .length = null,
        .perror = ParserErrors.OK,
    };

    for (csv.data.rows, 0..csv.data.num_rows) |row, i| {
        if (row.num_cols > num_cols) {
            res.valid = false;
            res.row = i + 1;
            res.length = row.num_cols;
            res.perror = ParserErrors.InvalidColCountPlus;
            return res;
        }

        if (row.num_cols < num_cols) {
            res.valid = false;
            res.row = i + 1;
            res.length = row.num_cols;
            res.perror = ParserErrors.InvalidColCountMinus;
            return res;
        }
    }

    return res;
}
