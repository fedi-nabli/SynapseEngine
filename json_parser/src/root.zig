// root.zig - Root file for JSON Parser
// This file contains the main functions for parsing and freeing JSON data,
// as well as managing the global allocator.
//
// Author: Fedi Nabli
// Date: 12 May 2025
// Last Modified: 12 May 2025

const std = @import("std");

const Json = @import("json.zig").Json;

const parser = @import("parser.zig");

// Global static allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// Reference to the allocator interface
const global_allocator = gpa.allocator();

pub export fn json_parser_parse(
    buffer_ptr: [*]const u8,
    buffer_len: usize,
) ?*Json {
    const buf = buffer_ptr[0..buffer_len];
    const json_ptr = global_allocator.create(Json) catch return null;

    parser.parser_parse_body(global_allocator, json_ptr, buf) catch {
        global_allocator.destroy(json_ptr);
        return null;
    };

    return json_ptr;
}

pub export fn json_parser_free(json: *Json) void {
    // Free schema version
    if (json.schema_version != null)
        global_allocator.free(std.mem.sliceTo(json.schema_version.?, 0));

    // Free run id
    if (json.run_id != null)
        global_allocator.free(std.mem.sliceTo(json.run_id.?, 0));

    // Free model name
    if (json.model_name != null)
        global_allocator.free(std.mem.sliceTo(json.model_name.?, 0));

    // Free model type
    if (json.model_type != null)
        global_allocator.free(std.mem.sliceTo(json.model_type.?, 0));

    // Free target
    if (json.target != null)
        global_allocator.free(std.mem.sliceTo(json.target.?, 0));

    // Free weights array
    if (json.weights.len > 0)
        global_allocator.free(json.weights);

    global_allocator.destroy(json);
}
