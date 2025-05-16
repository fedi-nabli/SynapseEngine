// test_parser.zig - Tests for SYNJ Parser
//
// This file contains tests for the SYNJ parser implementation
//
// Author: Fedi Nabli
// Date: 16 May 2025
// Last Modified: 16 May 2025

const std = @import("std");
const testing = std.testing;
const parser = @import("parser.zig");
const nodes = @import("node.zig");
const Node = nodes.Node;
const NodeType = nodes.NodeType;

fn print_ast(node: *Node, indent: usize) void {
    // Create indentation string
    var indent_str: [64]u8 = undefined;
    for (0..indent) |i| {
        indent_str[i] = ' ';
    }
    const indent_slice = indent_str[0..indent];

    // Print node type and specific details based on node type
    const stdout = std.io.getStdOut().writer();

    switch (node.node_type) {
        .Program => {
            stdout.print("{s}Program Node:\n", .{indent_slice}) catch return;
            for (node.value.Program.stmts) |stmt| {
                print_ast(stmt, indent + 4);
            }
        },
        .Assignment => {
            stdout.print("{s}Assignment Node:\n", .{indent_slice}) catch return;
            stdout.print("{s}Key:\n", .{indent_slice}) catch return;
            print_ast(node.value.Assignment.name, indent + 4);
            stdout.print("{s}Value:\n", .{indent_slice}) catch return;
            print_ast(node.value.Assignment.value, indent + 4);
        },
        .Keyword => {
            stdout.print("{s}Keyword: '{s}'\n", .{ indent_slice, node.value.Keyword }) catch return;
        },
        .StringLiteral => {
            stdout.print("{s}String: \"{s}\"\n", .{ indent_slice, node.value.StringLiteral }) catch return;
        },
        .NumberLiteral => {
            switch (node.value.NumberLiteral) {
                .Int => |value| stdout.print("{s}Integer: {d}\n", .{ indent_slice, value }) catch return,
                .Float => |value| stdout.print("{s}Float: {d}\n", .{ indent_slice, value }) catch return,
            }
        },
        .NullLiteral => {
            stdout.print("{s}Null\n", .{indent_slice}) catch return;
        },
        .ArrayLiteral => {
            stdout.print("{s}Array Node:\n", .{indent_slice}) catch return;
            for (node.value.ArrayLiteral.elems) |elem| {
                print_ast(elem, indent + 4);
            }
        },
        .ObjectLiteral => {
            stdout.print("{s}Object Node:\n", .{indent_slice}) catch return;
            for (node.value.ObjectLiteral.props) |prop| {
                print_ast(prop, indent + 4);
            }
        },
        .KeyValuePair => {
            stdout.print("{s}KeyValue Node:\n", .{indent_slice}) catch return;
            stdout.print("{s}Key:\n", .{indent_slice}) catch return;
            print_ast(node.value.KeyValuePair.key, indent + 4);
            stdout.print("{s}Value:\n", .{indent_slice}) catch return;
            print_ast(node.value.KeyValuePair.value, indent + 4);
        },
    }
}

test "Parse and verify nodes" {
    // Sample SYNJ input with different node types
    const input =
        \\model_name = "Test Model";
        \\algorithm = LinearRegression;
        \\train_test_split = [80, 20];
        \\batch_size = NULL;
        \\early_stop = { "patience": 5 };
    ;

    // const input =
    //     \\model_name = "Iris Flowers";
    //     \\algorithm = LinearRegression;
    //     \\csv_path = "data/iris.csv";
    //     \\train_test_split = [80, 20];
    //     \\target = "flower_class";
    //     \\features = [
    //     \\  "petal_length",
    //     \\  "petal_width",
    //     \\  "sepal_length",
    //     \\  "sepal_width"
    //     \\];
    //     \\classes = ["setosa", "nacrimosa"];
    //     \\epochs = 10;
    //     \\learning_rate = 0.01;
    //     \\batch_size = NULL;
    //     \\early_stop = { "patience": 5 };
    //     \\output_path = "model/model.json";
    // ;

    // Parse the input
    const alloc = std.testing.allocator;
    const root_node = try parser.parser_parse_body(alloc, input, input.len);
    defer nodes.node_free(alloc, root_node);

    // Print the AST for visual inspection
    std.debug.print("\n--- AST Structure ---\n", .{});
    print_ast(root_node, 0);
    std.debug.print("--------------------\n\n", .{});

    // Root should be a program node
    try testing.expectEqual(NodeType.Program, root_node.node_type);

    // Program should have 5 statements (5 assignments in our input)
    try testing.expectEqual(@as(usize, 5), root_node.value.Program.stmts.len);

    // Check first assignment: model_name = "Test Model"
    {
        const stmt1 = root_node.value.Program.stmts[0];
        try testing.expectEqual(NodeType.Assignment, stmt1.node_type);

        try testing.expectEqual(NodeType.Keyword, stmt1.value.Assignment.name.node_type);
        try testing.expectEqualStrings("model_name", stmt1.value.Assignment.name.value.Keyword);

        try testing.expectEqual(NodeType.StringLiteral, stmt1.value.Assignment.value.node_type);
        try testing.expectEqualStrings("Test Model", stmt1.value.Assignment.value.value.StringLiteral);
    }

    // Check second assignment: algorithm = LinearRegression
    {
        const stmt2 = root_node.value.Program.stmts[1];
        try testing.expectEqual(NodeType.Assignment, stmt2.node_type);

        try testing.expectEqual(NodeType.Keyword, stmt2.value.Assignment.value.node_type);
        try testing.expectEqualStrings("LinearRegression", stmt2.value.Assignment.value.value.Keyword);
    }

    // Check third assignment: train_test_split = [80, 20]
    {
        const stmt3 = root_node.value.Program.stmts[2];
        try testing.expectEqual(NodeType.Assignment, stmt3.node_type);

        try testing.expectEqual(NodeType.ArrayLiteral, stmt3.value.Assignment.value.node_type);
        try testing.expectEqual(@as(usize, 2), stmt3.value.Assignment.value.value.ArrayLiteral.elems.len);

        // Check first element (80)
        const elem1 = stmt3.value.Assignment.value.value.ArrayLiteral.elems[0];
        try testing.expectEqual(NodeType.NumberLiteral, elem1.node_type);
        try testing.expectEqual(std.meta.Tag(nodes.NumberValue).Int, std.meta.activeTag(elem1.value.NumberLiteral));
        try testing.expectEqual(@as(u64, 80), elem1.value.NumberLiteral.Int);

        // Check second element (20)
        const elem2 = stmt3.value.Assignment.value.value.ArrayLiteral.elems[1];
        try testing.expectEqual(NodeType.NumberLiteral, elem2.node_type);
        try testing.expectEqual(std.meta.Tag(nodes.NumberValue).Int, std.meta.activeTag(elem2.value.NumberLiteral));
        try testing.expectEqual(@as(u64, 20), elem2.value.NumberLiteral.Int);
    }

    // Check fourth assignment: batch_size = NULL
    {
        const stmt4 = root_node.value.Program.stmts[3];
        try testing.expectEqual(NodeType.Assignment, stmt4.node_type);
        try testing.expectEqual(NodeType.NullLiteral, stmt4.value.Assignment.value.node_type);
    }

    // Check fifth assignment: early_stop = { "patience": 5 }
    {
        const stmt5 = root_node.value.Program.stmts[4];
        try testing.expectEqual(NodeType.Assignment, stmt5.node_type);

        try testing.expectEqual(NodeType.ObjectLiteral, stmt5.value.Assignment.value.node_type);
        try testing.expectEqual(@as(usize, 1), stmt5.value.Assignment.value.value.ObjectLiteral.props.len);

        // Check key-value pair
        const prop = stmt5.value.Assignment.value.value.ObjectLiteral.props[0];
        try testing.expectEqual(NodeType.KeyValuePair, prop.node_type);

        // Check key
        try testing.expectEqual(NodeType.StringLiteral, prop.value.KeyValuePair.key.node_type);
        try testing.expectEqualStrings("patience", prop.value.KeyValuePair.key.value.StringLiteral);

        // Check value
        try testing.expectEqual(NodeType.NumberLiteral, prop.value.KeyValuePair.value.node_type);
        try testing.expectEqual(std.meta.Tag(nodes.NumberValue).Int, std.meta.activeTag(prop.value.KeyValuePair.value.value.NumberLiteral));
        try testing.expectEqual(@as(u64, 5), prop.value.KeyValuePair.value.value.NumberLiteral.Int);
    }

    // In a real implementation, you would need to properly free the nodes
    // to avoid memory leaks
}
