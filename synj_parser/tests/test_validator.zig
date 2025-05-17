// test_validator.zig - Tests for SYNJ Validator
//
// This file contains tests for the SYNJ validator implementation
//
// Author: Fedi Nabli
// Date: 15 May 2025
// Last Modified: 17 May 2025

const std = @import("std");
const testing = std.testing;
const Synj = @import("synj.zig").Synj;
const ModelType = @import("synj.zig").ModelType;
const EarlyStop = @import("synj.zig").EarlyStop;

// Import the functions to test
const root = @import("root.zig");
const synj_parser_parse = root.synj_parser_parse;
const synj_parser_free = root.synj_parser_free;

test "Parse valid SYNJ configuration" {
    const test_name = "Parse valid SYNJ configuration";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // Valid SYNJ configuration string
    const valid_synj =
        \\model_name = "Iris Classifier";
        \\algorithm = LinearRegression;
        \\csv_path = "data/iris.csv";
        \\train_test_split = [80, 20];
        \\target = "species";
        \\features = ["sepal_length", "sepal_width", "petal_length", "petal_width"];
        \\classes = ["setosa", "versicolor", "virginica"];
        \\epochs = 100;
        \\learning_rate = 0.01;
        \\batch_size = 32;
        \\early_stop = { "patience": 10 };
        \\output_path = "output/model.json";
    ;

    // Parse the valid configuration
    const synj_ptr = synj_parser_parse(valid_synj, valid_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    // Verify we got a valid configuration
    try testing.expect(synj_ptr != null);

    // Check the values
    const config = synj_ptr.?;
    try testing.expectEqualStrings("Iris Classifier", std.mem.span(config.model_name.?));
    try testing.expectEqual(ModelType.LinearRegression, config.model_type);
    try testing.expectEqualStrings("data/iris.csv", std.mem.span(config.csv_path.?));
    try testing.expectEqual(@as(u8, 80), config.train_test_split[0]);
    try testing.expectEqual(@as(u8, 20), config.train_test_split[1]);
    try testing.expectEqualStrings("species", std.mem.span(config.target.?));

    // Check features (which is a string array)
    const features = config.features.?;
    try testing.expectEqualStrings("sepal_length", std.mem.span(features[0]));
    try testing.expectEqualStrings("sepal_width", std.mem.span(features[1]));
    try testing.expectEqualStrings("petal_length", std.mem.span(features[2]));
    try testing.expectEqualStrings("petal_width", std.mem.span(features[3]));

    // Check classes (which is a string array)
    const classes = config.classes.?;
    try testing.expectEqualStrings("setosa", std.mem.span(classes[0]));
    try testing.expectEqualStrings("versicolor", std.mem.span(classes[1]));
    try testing.expectEqualStrings("virginica", std.mem.span(classes[2]));

    try testing.expectEqual(@as(u32, 100), config.epochs);
    try testing.expectEqual(@as(f64, 0.01), config.learning_rate);
    try testing.expectEqual(@as(u32, 32), config.batch_size);
    try testing.expectEqual(@as(u32, 10), config.early_stop.?.patience);
    try testing.expectEqualStrings("output/model.json", std.mem.span(config.output_path.?));
}

test "Parse SYNJ with minimal required fields" {
    const test_name = "Parse SYNJ with minimal required fields";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // SYNJ with only required fields, others use defaults
    const minimal_synj =
        \\model_name = "Simple Model";
        \\algorithm = LogisticRegression;
        \\csv_path = "data.csv";
        \\train_test_split = [70, 30];
        \\target = "target_column";
        \\features = ["feature1", "feature2"];
        \\epochs = 10;
    ;

    // Parse the minimal configuration
    const synj_ptr = synj_parser_parse(minimal_synj, minimal_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    // Verify we got a valid configuration
    try testing.expect(synj_ptr != null);

    // Check the required values
    const config = synj_ptr.?;
    try testing.expectEqualStrings("Simple Model", std.mem.span(config.model_name.?));
    try testing.expectEqual(ModelType.LogisticRegression, config.model_type);
    try testing.expectEqualStrings("data.csv", std.mem.span(config.csv_path.?));
    try testing.expectEqual(@as(u8, 70), config.train_test_split[0]);
    try testing.expectEqual(@as(u8, 30), config.train_test_split[1]);
    try testing.expectEqualStrings("target_column", std.mem.span(config.target.?));

    const features = config.features.?;
    try testing.expectEqualStrings("feature1", std.mem.span(features[0]));
    try testing.expectEqualStrings("feature2", std.mem.span(features[1]));

    try testing.expectEqual(@as(u32, 10), config.epochs);

    // Check default values
    try testing.expectEqual(@as(f64, 0.01), config.learning_rate); // Default
    try testing.expectEqual(@as(u32, 0), config.batch_size); // Default: null
    try testing.expectEqual(@as(?EarlyStop, null), config.early_stop); // Default: null
    try testing.expectEqualStrings("model/model.json", std.mem.span(config.output_path.?)); // Default
}

test "Parse invalid SYNJ - missing required field" {
    const test_name = "Parse invalid SYNJ - missing required field";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // Missing target field
    const invalid_synj =
        \\model_name = "Bad Model";
        \\algorithm = LinearRegression;
        \\csv_path = "data.csv";
        \\train_test_split = [80, 20];
        \\features = ["f1", "f2"];
        \\epochs = 5;
    ;

    // Parse should return null for invalid config
    const synj_ptr = synj_parser_parse(invalid_synj, invalid_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    try testing.expectEqual(@as(?*Synj, null), synj_ptr);
}

test "Parse invalid SYNJ - syntax error" {
    const test_name = "Parse invalid SYNJ - syntax error";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // Missing semicolon on line 2
    const invalid_synj =
        \\model_name = "Syntax Error Model";
        \\algorithm = LinearRegression // Missing semicolon
        \\csv_path = "data.csv";
        \\train_test_split = [80, 20];
        \\target = "class";
        \\features = ["f1", "f2"];
        \\epochs = 5;
    ;

    // Parse should return null for invalid syntax
    const synj_ptr = synj_parser_parse(invalid_synj, invalid_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    try testing.expectEqual(@as(?*Synj, null), synj_ptr);
}

test "Parse invalid SYNJ - incorrect type" {
    const test_name = "Parse invalid SYNJ - incorrect type";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // features should be an array of strings, not an integer
    const invalid_synj =
        \\model_name = "Type Error Model";
        \\algorithm = LinearRegression;
        \\csv_path = "data.csv";
        \\train_test_split = [80, 20];
        \\target = "class";
        \\features = 123; // Should be array of strings
        \\epochs = 5;
    ;

    // Parse should return null for invalid types
    const synj_ptr = synj_parser_parse(invalid_synj, invalid_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    try testing.expectEqual(@as(?*Synj, null), synj_ptr);
}

test "Parse invalid SYNJ - invalid train_test_split" {
    const test_name = "Parse invalid SYNJ - invalid train_test_split";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // train_test_split should sum to 100
    const invalid_synj =
        \\model_name = "Split Error Model";
        \\algorithm = LinearRegression;
        \\csv_path = "data.csv";
        \\train_test_split = [60, 30]; // Doesn't sum to 100
        \\target = "class";
        \\features = ["f1", "f2"];
        \\epochs = 5;
    ;

    // Parse should return null for invalid train_test_split
    const synj_ptr = synj_parser_parse(invalid_synj, invalid_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    try testing.expectEqual(@as(?*Synj, null), synj_ptr);
}

test "Parse invalid SYNJ - invalid early_stop" {
    const test_name = "Parse invalid SYNJ - invalid early_stop";
    std.debug.print("\n----- Starting Test: {s} -----\n", .{test_name});
    defer std.debug.print("----- End Test: {s} -----\n\n", .{test_name});

    // patience must be less than epochs
    const invalid_synj =
        \\model_name = "Early Stop Error";
        \\algorithm = LinearRegression;
        \\csv_path = "data.csv";
        \\train_test_split = [80, 20];
        \\target = "class";
        \\features = ["f1", "f2"];
        \\epochs = 5;
        \\early_stop = { "patience": 10 }; // patience > epochs
    ;

    // Parse should return null for invalid early_stop
    const synj_ptr = synj_parser_parse(invalid_synj, invalid_synj.len);
    defer if (synj_ptr != null) synj_parser_free(synj_ptr.?);

    try testing.expectEqual(@as(?*Synj, null), synj_ptr);
}
