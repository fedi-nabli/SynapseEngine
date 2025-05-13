// json.zig - JOSN Structure definitions
// This file defines structure related to
// the JSON structure to be parsed for the final model output
//
// Author: Fedi Nabli
// Date: 12 May 2025
// Last Modified: 13 May 2025

const std = @import("std");

pub const ModelType = enum {
    LinearRegression,
    LogisticRegression,

    pub fn from_string(str: []const u8) ?ModelType {
        if (std.mem.eql(u8, str, "LinearRegression")) return .LinearRegression;
        if (std.mem.eql(u8, str, "LogisticRegression")) return .LogisticRegression;
        return null;
    }
};

pub const Json = struct {
    schema_version: ?[*:0]u8,
    run_id: ?[*:0]u8,
    model_name: ?[*:0]u8,
    model_type: ?[*:0]u8,
    target: ?[*:0]u8,
    epochs_trained: u32,
    final_loss: f64,
    weights: []f64,
    bias: f64,

    pub fn init() Json {
        return Json{
            .schema_version = null,
            .run_id = null,
            .model_name = null,
            .model_type = null,
            .target = null,
            .epochs_trained = 0,
            .final_loss = -1,
            .weights = &[_]f64{},
            .bias = -1,
        };
    }
};
