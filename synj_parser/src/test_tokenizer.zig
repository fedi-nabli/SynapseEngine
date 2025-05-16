// test_tokenizer.zig - Tests for SYNJ Tokenizer
//
// This file contains tests for the SYNJ tokenizer implementation
//
// Author: Fedi Nabli
// Date: 15 May 2025
// Last Modified: 16 May 2025

const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const Lexer = @import("lexer.zig").Lexer;
const Tokenizer = @import("tokenizer.zig").Tokenizer;
const Token = @import("tokenizer.zig").Token;
const TokenType = @import("tokenizer.zig").TokenType;
const TokenNumType = @import("tokenizer.zig").TokenNumType;
const TokenVal = @import("tokenizer.zig").TokenVal;

// Helper function to print a token for debugging
fn printToken(token: Token, writer: anytype) !void {
    try writer.print("Token {{ type: {s}, ", .{@tagName(token.type)});

    // Print position
    try writer.print("pos: ({d},{d}), ", .{ token.pos.line, token.pos.col });

    // Print value based on type
    switch (token.type) {
        .KEYWORD => try writer.print("value: \"{s}\", ", .{token.value.sval}),
        .NULL_LITERAL => try writer.print("value: NULL, ", .{}),
        .STRING_LITERAL => try writer.print("value: {s}, ", .{token.value.sval}),
        .NUMBER_LITERAL => {
            if (token.num_type) |num_type| {
                switch (num_type) {
                    .TOKEN_INTEGER => try writer.print("value: {d}, ", .{token.value.inum}),
                    .TOKEN_FLOAT => try writer.print("value: {d:.6}, ", .{token.value.lnum}),
                }
            }
        },
        else => try writer.print("value: '{c}', ", .{token.value.cval}),
    }

    try writer.print("lexeme: \"{s}\" }}\n", .{token.lexeme});
}

// Test function that tokenizes a sample SYNJ file and prints all tokens
test "Tokenize SYNJ Sample" {
    // Sample SYNJ input
    const input =
        \\model_name = "Iris Flowers";
        \\algorithm = LinearRegression;
        \\csv_path = "data/iris.csv";
        \\train_test_split = [80, 20];
        \\target = "flower_class";
        \\features = [
        \\  "petal_length",
        \\  "petal_width",
        \\  "sepal_length",
        \\  "sepal_width"
        \\];
        \\classes = ["setosa", "nacrimosa"];
        \\epochs = 10;
        \\learning_rate = 0.01;
        \\batch_size = NULL;
        \\early_stop = { "patience": 5 };
        \\output_path = "model/model.json";
    ;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n--- SYNJ Tokenizer Test ---\n\n", .{});
    try stdout.print("Input:\n{s}\n\n", .{input});

    // Initialize lexer and tokenizer
    var lexer = Lexer.init(input, input.len);
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var tokenizer_instance = Tokenizer.init(&lexer, arena.allocator());

    // Collect all tokens
    var tokens = std.ArrayList(Token).init(arena.allocator());
    defer tokens.deinit();

    try stdout.print("Tokens:\n", .{});

    // Use next_token to read all tokens until EOF
    while (true) {
        const token = tokenizer_instance.next_token() catch |err| {
            try stdout.print("Error during tokenization: {}\n", .{err});
            break;
        };

        try tokens.append(token);
        try printToken(token, stdout);

        if (token.type == .EOF) {
            break;
        }
    }

    try stdout.print("\nTotal tokens: {d}\n", .{tokens.items.len});
}

// Test function specifically for testing string tokenization
test "Tokenize Strings with Escapes" {
    // Sample with various string escapes
    const input =
        \\"Simple string"
        \\"String with \\\"quotes\\\""
        \\"String with \\n newline"
        \\"String with \\t tab"
        \\"Backslash \\\\"
    ;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n--- String Escape Test ---\n\n", .{});

    // Initialize lexer and tokenizer
    var lexer = Lexer.init(input, input.len);
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var tokenizer_instance = Tokenizer.init(&lexer, arena.allocator());

    // Test string escapes
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        const token = tokenizer_instance.next_token() catch |err| {
            try stdout.print("Error during string tokenization: {}\n", .{err});
            break;
        };

        try printToken(token, stdout);

        // Verify it's a string token
        try testing.expect(token.type == .STRING_LITERAL);
    }
}

// Test function for numeric tokenization
test "Tokenize Numbers" {
    // Sample with various numbers
    const input =
        \\123
        \\0
        \\3.14159
        \\0.5
        \\42
    ;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n--- Number Test ---\n\n", .{});

    // Initialize lexer and tokenizer
    var lexer = Lexer.init(input, input.len);
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var tokenizer_instance = Tokenizer.init(&lexer, arena.allocator());

    // Test numbers
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        const token = tokenizer_instance.next_token() catch |err| {
            try stdout.print("Error during number tokenization: {}\n", .{err});
            break;
        };

        try printToken(token, stdout);

        // Verify it's a number token
        try testing.expect(token.type == .NUMBER_LITERAL);
    }
}

// Test function for keyword and NULL tokenization
test "Tokenize Keywords and NULL" {
    // Sample with keywords and NULL
    const input =
        \\NULL
        \\LinearRegression
        \\LogisticRegression
        \\model_name
    ;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n--- Keyword and NULL Test ---\n\n", .{});

    // Initialize lexer and tokenizer
    var lexer = Lexer.init(input, input.len);
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var tokenizer_instance = Tokenizer.init(&lexer, arena.allocator());

    // Expected token types
    const expected_types = [_]TokenType{
        .NULL_LITERAL,
        .KEYWORD,
        .KEYWORD,
        .KEYWORD,
    };

    // Test keywords and NULL
    var i: usize = 0;
    while (i < expected_types.len) : (i += 1) {
        const token = tokenizer_instance.next_token() catch |err| {
            try stdout.print("Error during keyword tokenization: {}\n", .{err});
            break;
        };

        try printToken(token, stdout);

        // Verify token type
        try testing.expect(token.type == expected_types[i]);
    }
}
