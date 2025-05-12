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

fn parser_parse_statements(
    allocator: std.mem.Allocator,
    buffer: []const u8,
) !void {
    _ = buffer;
    _ = allocator;
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

    parser_parse_statements(allocator, data) catch |err| {
        stdout.print("Error parsing json data\n", .{});
        return err;
    };
}
