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

const JsonKeys = enum {
    schema_version,
    run_id,
    model_name,
    model_type,
    target,
    epochs_trained,
    final_loss,
    weights,
    bias,
    unknown,
};

fn str_to_key(key_str: []const u8) JsonKeys {
    if (std.mem.eql(u8, key_str, "schema_version")) return .schema_version;
    if (std.mem.eql(u8, key_str, "run_id")) return .run_id;
    if (std.mem.eql(u8, key_str, "model_name")) return .model_name;
    if (std.mem.eql(u8, key_str, "model_type")) return .model_type;
    if (std.mem.eql(u8, key_str, "target")) return .target;
    if (std.mem.eql(u8, key_str, "epochs_trained")) return .epochs_trained;
    if (std.mem.eql(u8, key_str, "final_loss")) return .final_loss;
    if (std.mem.eql(u8, key_str, "weights")) return .weights;
    if (std.mem.eql(u8, key_str, "bias")) return .bias;
    return .unknown;
}

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

fn parser_parse_string(
    allocator: std.mem.Allocator,
    value: []const u8,
    field: *?[*:0]u8,
) !void {
    const stdout = std.io.getStdOut().writer();

    // String values must be surrounded by quotes
    if (value.len < 2 or value[0] != '"' or value[value.len - 1] != '"') {
        try stdout.print("String value must be surrounded by quotes: {s}\n", .{value});
        return JsonParserErrors.StringParseError;
    }

    // Extract the actual string
    const content = value[1 .. value.len - 1];
    const null_terminated_string = try allocator.dupeZ(u8, content);

    // Set the field to the new string
    field.* = null_terminated_string;
}

fn parser_parse_int(
    value: []const u8,
    field: *u32,
) !void {
    const stdout = std.io.getStdOut().writer();

    // Trim whitespace from value
    var start: usize = 0;
    var end: usize = value.len;

    while (start < end and is_skip_character(value[start])) : (start += 1) {}
    while (end > start and is_skip_character(value[end - 1])) : (end -= 1) {}

    const trimmed = value[start..end];

    field.* = std.fmt.parseInt(u32, trimmed, 10) catch {
        try stdout.print("Failed to parse integer: {s}\n", .{value});
        return JsonParserErrors.IntParseError;
    };
}

fn parser_parse_float(
    value: []const u8,
    field: *f64,
) !void {
    const stdout = std.io.getStdOut().writer();

    // Trim whitespace from value
    var start: usize = 0;
    var end: usize = value.len;

    while (start < end and is_skip_character(value[start])) : (start += 1) {}
    while (end > start and is_skip_character(value[end - 1])) : (end -= 1) {}

    const trimmed = value[start..end];

    field.* = std.fmt.parseFloat(f64, trimmed) catch {
        try stdout.print("Failed to parse float: {s}\n", .{value});
        return JsonParserErrors.FloatParseError;
    };
}

fn parser_parse_array(
    allocator: std.mem.Allocator,
    value: []const u8,
    field: *[]f64,
) !void {
    const stdout = std.io.getStdOut().writer();

    // Trim whiespace from value
    var start: usize = 0;
    var end: usize = value.len;

    while (start < end and is_skip_character(value[start])) : (start += 1) {}
    while (end > start and is_skip_character(value[end - 1])) : (end -= 1) {}

    const trimmed = value[start..end];

    if (trimmed[0] != '[' or trimmed[trimmed.len - 1] != ']') {
        try stdout.print("Expected array value, but instead got: {s}\n", .{trimmed});
        return JsonParserErrors.ArrayParseError;
    }

    // Get array content
    const array_content = trimmed[1 .. trimmed.len - 1];

    // Count number of values (comma seperated)
    var count: usize = 1;
    for (array_content) |char| {
        if (char == ',') count += 1;
    }

    // Allocate array
    var array = try allocator.alloc(f64, count);
    var array_index: usize = 0;

    // Parse each number
    var num_start: usize = 0;
    var pos: usize = 0;
    while (pos <= array_content.len) : (pos += 1) {
        if (pos == array_content.len or array_content[pos] == ',') {
            const num_str = array_content[num_start..pos];

            // Trim whitespace
            var num_trim_start: usize = 0;
            var num_trim_end: usize = num_str.len;
            while (num_trim_start < num_trim_end and is_skip_character(num_str[num_trim_start])) : (num_trim_start += 1) {}
            while (num_trim_end > num_trim_start and is_skip_character(num_str[num_trim_end - 1])) : (num_trim_end -= 1) {}

            const trimmed_num = num_str[num_trim_start..num_trim_end];

            array[array_index] = std.fmt.parseFloat(f64, trimmed_num) catch {
                allocator.free(array);
                try stdout.print("Failed to parse number in array: {s}\n", .{trimmed_num});
                return JsonParserErrors.ArrayParseError;
            };

            array_index += 1;
            num_start = pos + 1;
        }
    }

    field.* = array;
}

fn parser_parse_value(
    allocator: std.mem.Allocator,
    key: []const u8,
    value: []const u8,
    json: *Json,
) !void {
    const stdout = std.io.getStdOut().writer();

    const key_num = str_to_key(key);

    switch (key_num) {
        .schema_version => try parser_parse_string(allocator, value, &json.schema_version),
        .run_id => try parser_parse_string(allocator, value, &json.run_id),
        .model_name => try parser_parse_string(allocator, value, &json.model_name),
        .model_type => try parser_parse_string(allocator, value, &json.model_type),
        .target => try parser_parse_string(allocator, value, &json.target),
        .epochs_trained => try parser_parse_int(value, &json.epochs_trained),
        .final_loss => try parser_parse_float(value, &json.final_loss),
        .weights => try parser_parse_array(allocator, value, &json.weights),
        .bias => try parser_parse_float(value, &json.bias),
        .unknown => {
            try stdout.print("Unknown Key: {s}\n", .{key});
            return JsonParserErrors.UnknownKey;
        },
    }
}

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

    try parser_parse_value(allocator, unqoted_key, value, json);
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
