// parser.zig - CSV parser functions
// This file implements different functions to
// parse the JSON file, handles edge-cases and validate
// the JSON format input
//
// Author: Fedi Nabli
// Date: 12 May 2025
// Last Modified: 12 May 2025

const std = @import("std");

const Json = @import("json.zig").Json;
const JsonParserErrors = @import("error.zig").JsonParserErrors;

fn is_skip_character(char: u8) bool {
    return (char == ' ' or char == '\t' or char == '\n' or char == '\r');
}

fn skip_whitespaces(
    buffer: []const u8,
    c: usize,
) usize {
    var pos = c;
    while (pos < buffer.len and is_skip_character(buffer[pos]))
        pos += 1;

    return pos;
}

fn parser_parse_string() !void {}

fn parser_parse_int() !void {}

fn parser_parse_float() !void {}

fn parser_parse_array() !void {}

fn parser_parse_value() !void {}

fn parser_parse_key(key: []const u8) ![]const u8 {
    const stdout = std.io.getStdOut().writer();

    // Trim whitespace
    var start: usize = 0;
    var end: usize = key.len;

    while (start < end and is_skip_character(key[start])) : (start += 1) {}
    while (end > start and is_skip_character(key[end - 1])) : (end -= 1) {}

    if (start >= end) {
        try stdout.print("Empty key after trimming whitespaces\n", .{});
        return JsonParserErrors.EmptyKey;
    }

    // Key must be surrounded by '"' (quotes)
    if (key[start] != '"' or key[end - 1] != '"') {
        try stdout.print("Key must be surrounded by quotes\n", .{});
        return JsonParserErrors.InvalidKey;
    }

    // return key without quotes
    return key[start + 1 .. end - 1];
}

fn parser_parse_statement(
    allocator: std.mem.Allocator,
    statement: []const u8,
    json: *Json,
) !void {
    _ = allocator;
    _ = json;

    const stdout = std.io.getStdOut().writer();

    var start: usize = 0;
    var end: usize = statement.len;

    // Trim leading whitespace
    while (start < end and is_skip_character(statement[start])) : (start += 1) {}
    // Trim trailing whitespace
    while (end > start and is_skip_character(statement[end])) : (end -= 1) {}

    if (start >= end) {
        try stdout.print("Empty statement after trimming whitespaces\n", .{});
        return JsonParserErrors.EmptyStatement;
    }

    // Split into key and value by ':'
    var colon_pos: usize = 0;
    while (colon_pos < end - start) : (colon_pos += 1) {
        if (statement[start + colon_pos] == ':')
            break;
    }

    if (colon_pos >= end - start) {
        try stdout.print("Missing ':' in statement\n", .{});
        return JsonParserErrors.MissingColon;
    }

    // Extract key and value parts
    const key = statement[start .. start + colon_pos];
    const value_untrimmed = statement[start + colon_pos + 1 .. end];

    // Trim whitespaces from value
    var value_start: usize = 0;
    var value_end: usize = value_untrimmed.len;

    while (value_start < value_end and is_skip_character(value_untrimmed[value_start])) : (value_start += 1) {}
    while (value_end > value_start and is_skip_character(value_untrimmed[value_end - 1])) : (value_end -= 1) {}

    if (value_start >= value_end) {
        try stdout.print("Empty value after trimming whitespaces\n", .{});
        return JsonParserErrors.EmptyValue;
    }

    const value = value_untrimmed[value_start..value_end];

    const unqoted_key = try parser_parse_key(key);
    try stdout.print("Unquoted Key: {s}\n", .{unqoted_key});

    try stdout.print("Value: {s}\n", .{value});
}

fn parser_parse_statements(
    allocator: std.mem.Allocator,
    buffer: []const u8,
    json: *Json,
) !void {
    const stdout = std.io.getStdOut().writer();

    var start: usize = 0;
    var in_string: bool = false;
    var in_array: bool = false;
    var pos: usize = 0;

    while (pos < buffer.len) : (pos += 1) {
        switch (buffer[pos]) {
            '"' => {
                // Toggle string mode, but ignore escaped quoted
                if (pos == 0 or buffer[pos - 1] != '\\') {
                    in_string = !in_string;
                }
            },
            '[' => {
                in_array = true;
            },
            ']' => {
                in_array = false;
            },
            ',' => {
                if (!in_string and !in_array) {
                    // Found statement seperator
                    const statement = buffer[start..pos];
                    try stdout.print("Found statement: {s}\n", .{statement});
                    if (statement.len == 0) {
                        try stdout.print("Expected key value pair, found ','\n", .{});
                        return JsonParserErrors.EmptyStatement;
                    }

                    // Parse statement
                    parser_parse_statement(allocator, statement, json) catch |err| {
                        return err;
                    };

                    pos += 1;
                    pos = skip_whitespaces(buffer, pos);
                    start = pos;
                    pos -= 1; // componsate for the wile loop + 1
                }
            },
            else => {},
        }
    }

    if (start < buffer.len) {
        const statement = buffer[start..];
        try stdout.print("Found last statement: {s}\n", .{statement});
        parser_parse_statement(allocator, statement, json) catch |err| {
            return err;
        };
    }
}

pub fn parser_parse_body(
    allocator: std.mem.Allocator,
    json: *Json,
    buffer: []const u8,
) !void {
    const stdout = std.io.getStdOut().writer();

    json.* = Json.init();
    var count: usize = 0;
    count = skip_whitespaces(buffer, count);

    if (buffer[count] != '{') {
        try stdout.print("Expected '{{', but found {c}\n", .{buffer[count]});
        return JsonParserErrors.ExpectedStartToken;
    }
    count += 1;

    // Empty object, valid json but not for our purposes
    count = skip_whitespaces(buffer, count);
    if (buffer[count] == '}') {
        try stdout.print("Unexpected '}}' before actual data\n", .{});
        return JsonParserErrors.UnexpectedEndToken;
    }

    var end: usize = count;
    while (end < buffer.len) : (end += 1) {
        if (buffer[end] == '}')
            break;
    }
    if (end >= buffer.len) {
        try stdout.print("Error: missing '}}' at the end of json file\n", .{});
        return JsonParserErrors.ExpectedEndToken;
    }

    const after_end_data = skip_whitespaces(buffer, end + 1);
    if (after_end_data < buffer.len) {
        try stdout.print("Unexpected content after closing brace\n", .{});
        return JsonParserErrors.UnexpectedEndToken;
    }

    const data = buffer[count..end];
    try stdout.print("Json Data: {s}\n", .{data});

    var last_char: usize = data.len - 1;
    while (last_char > 0 and is_skip_character(data[last_char])) : (last_char -= 1) {}

    if (data[last_char] == ',') {
        try stdout.print("Error: Trailing comma at the end of data\n", .{});
        return JsonParserErrors.TrainlingComma;
    }

    parser_parse_statements(allocator, data, json) catch |err| {
        try stdout.print("Error parsing json data\n", .{});
        return err;
    };
}
