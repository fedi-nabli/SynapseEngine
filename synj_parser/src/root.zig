// root.zig - Root file for SYNJ Parser
//
// This file contains the main functions for parsing and freeing SYNJ data,
// as well as managing the global allocator.
//
// Author: Fedi Nabli
// Date: 14 May 2025
// Last Modified: 17 May 2025

const std = @import("std");

const Synj = @import("synj.zig").Synj;

const nodes = @import("node.zig");

const parser_parse_body = @import("parser.zig").parser_parse_body;

const validator = @import("validator.zig");

// Global static allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// Reference to the allocator interface
const global_allocator = gpa.allocator();

pub export fn synj_parser_parse(
    buffer_ptr: [*]const u8,
    buffer_len: usize,
) ?*Synj {
    const buf = buffer_ptr[0..buffer_len];
    const synj_ptr = global_allocator.create(Synj) catch return null;

    synj_ptr.* = Synj.init_default();

    const root_node = parser_parse_body(global_allocator, buf, buf.len) catch {
        global_allocator.destroy(synj_ptr);
        return null;
    };
    defer nodes.node_free(global_allocator, root_node);

    const validation_result = validator.validate_ast(global_allocator, root_node, synj_ptr) catch {
        global_allocator.destroy(synj_ptr);
        return null;
    };

    if (!validation_result) {
        return null;
    }

    return synj_ptr;
}

pub export fn synj_parser_free(synj: *Synj) void {
    if (synj.model_name != null) {
        global_allocator.free(std.mem.sliceTo(synj.model_name.?, 0));
    }

    if (synj.csv_path != null) {
        global_allocator.free(std.mem.sliceTo(synj.csv_path.?, 0));
    }

    if (synj.target != null) {
        global_allocator.free(std.mem.sliceTo(synj.target.?, 0));
    }

    if (synj.features != null) {
        for (0..synj.features_len) |idx| {
            global_allocator.free(std.mem.sliceTo(synj.features.?[idx], 0));
        }
        global_allocator.free(synj.features.?[0..synj.features_len]);
    }

    if (synj.classes != null) {
        for (0..synj.classes_len) |idx| {
            global_allocator.free(std.mem.sliceTo(synj.classes.?[idx], 0));
        }
        global_allocator.free(synj.classes.?[0..synj.classes_len]);
    }

    if (synj.output_path != null) {
        global_allocator.free(std.mem.sliceTo(synj.output_path.?, 0));
    }

    global_allocator.destroy(synj);
}
