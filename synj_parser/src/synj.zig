// synj.zig - SYNJ Structure definitions
//
// This file defines structures and enums related to
// the SYNJ DSL structure to be parsed for the model configuration
//
// Author: Fedi Nabli
// Date: 14 May 2025
// Last Modified: 14 May 2025

pub const ModelType = enum {
    LinearRegression,
    LogisticRegression,
};

pub const EarlyStop = struct {
    patience: u32,
};

pub const Synj = struct {
    model_name: ?[*:0]u8,
    model_type: ModelType,
    csv_path: ?[*:0]u8,
    target: ?[*:0]u8,
    train_test_split: [2]u8,
    features: ?[*][*:0]u8,
    features_len: usize,
    classes: ?[*][*:0]u8,
    classes_len: usize,
    epochs: u32,
    learning_rate: f64,
    batch_size: ?u32,
    early_stop: ?EarlyStop,
    output_path: ?[*:0]u8,

    pub fn init_default() Synj {
        return Synj{
            .model_name = null,
            .model_type = undefined,
            .csv_path = null,
            .target = null,
            .train_test_split = [2]u8{ 0, 0 },
            .features = null,
            .features_len = 0,
            .classes = null,
            .classes_len = 0,
            .epochs = 0,
            .learning_rate = 0.01,
            .batch_size = null,
            .early_stop = null,
            .output_path = null,
        };
    }
};
