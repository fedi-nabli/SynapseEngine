// root.zig - Root file for SYNJ Parser
//
// This file contains the main functions for parsing and freeing SYNJ data,
// as well as managing the global allocator.
//
// Author: Fedi Nabli
// Date: 14 May 2025
// Last Modified: 14 May 2025

const std = @import("std");

const Synj = @import("synj.zig").Synj;

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

    _ = buf;

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

    // TODO: free train test split array
    // TODO: free string array memory (features & classes)
    // TODO: free early stop

    if (synj.output_path != null) {
        global_allocator.free(std.mem.sliceTo(synj.output_path.?, 0));
    }

    global_allocator.destroy(synj);
}
