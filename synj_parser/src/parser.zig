// parser.zig - SYNJ AST parser functions
//
// This file defines structures and implements functions related to
// the SYNJ DSL parser
//
// Author: Fedi Nabli
// Date: 16 May 2025
// Last Modified: 16 May 2025

const std = @import("std");

const ParsingErrors = @import("error.zig").ParsingErrors;
const SynjErrors = @import("error.zig").SynjErrors;

const Lexer = @import("lexer.zig").Lexer;

const Tokenizer = @import("tokenizer.zig").Tokenizer;
const TokenType = @import("tokenizer.zig").TokenType;
const TokenPos = @import("tokenizer.zig").TokenPos;
const Token = @import("tokenizer.zig").Token;
const TokenNumType = @import("tokenizer.zig").TokenNumType;

const nodes = @import("node.zig");
const Node = @import("node.zig").Node;
const NodeSpan = @import("node.zig").NodeSpan;

pub const ParserError = struct {
    message: []const u8,
    // span: NodeSpan,
    pos: TokenPos,
};

pub const Parser = struct {
    tokenizer: *Tokenizer,
    allocator: std.mem.Allocator,
    errors: std.ArrayList(ParserError),

    pub fn init(tok: *Tokenizer, allocator: std.mem.Allocator) Parser {
        return Parser{
            .tokenizer = tok,
            .allocator = allocator,
            .errors = std.ArrayList(ParserError).init(allocator),
        };
    }

    /// Peek at next token without advancing
    fn peek(self: *Parser) Token {
        return self.tokenizer.peek_token() catch unreachable;
    }

    /// Consume current token, return next one
    fn advance(self: *Parser) Token {
        return self.tokenizer.next_token() catch unreachable;
    }

    /// Sees if next token matches the expected type
    fn match(self: *Parser, t: TokenType) bool {
        if (self.peek().type == t) {
            _ = self.advance();
            return true;
        }

        return false;
    }

    /// Function that sees if next token matches the expected one,
    /// otherwise register an error in the Parser
    fn expect(self: *Parser, t: TokenType, msg: []const u8) !void {
        if (!self.match(t)) {
            const tok_pos = self.peek().pos;
            try self.register_error(msg, tok_pos);
            return ParsingErrors.InvalidSyntax;
        }
    }

    fn unexpected_error(self: *Parser, message: []const u8) !void {
        const tok = self.peek();
        try self.register_error(message, tok.pos);
        self.synchronize();
        return ParsingErrors.InvalidSyntax;
    }

    /// Helper function to register a new error in the parser errors array
    fn register_error(self: *Parser, message: []const u8, pos: TokenPos) !void {
        try self.errors.append(ParserError{ .message = message, .pos = pos });
    }

    /// Checks if next token is the final token
    fn is_at_end(self: *Parser) bool {
        return self.peek().type == .EOF;
    }

    /// Skips until end of statement to continue parsing
    fn synchronize(self: *Parser) void {
        // Skip tokens until statement booundary to continue
        while (!self.is_at_end()) {
            if (self.peek().type == .SEMICOLON) {
                _ = self.advance();
                return;
            }
            _ = self.advance();
        }
    }

    fn parse(self: *Parser) !*Node {
        const stmts = try self.parse_program();
        const start_span = stmts[0].span;
        const end_span = stmts[stmts.len - 1].span;
        const span = NodeSpan{
            .start_line = start_span.start_line,
            .start_col = start_span.start_col,
            .end_line = end_span.end_line,
            .end_col = end_span.end_col,
        };
        return nodes.create_program_node(self.allocator, stmts, span);
    }

    fn parse_program(self: *Parser) ![]*Node {
        var stmts = std.ArrayList(*Node).init(self.allocator);
        while (!self.is_at_end()) {
            const stmt = try self.parse_statement();
            try stmts.append(stmt);
        }

        return stmts.toOwnedSlice();
    }

    fn parse_statement(self: *Parser) !*Node {
        if (self.peek().type == .KEYWORD) {
            const assign = try self.parse_assignement();
            errdefer nodes.node_free(self.allocator, assign);

            try self.expect(.SEMICOLON, "Expected ';' after assignement statement");
            return assign;
        }
        try self.unexpected_error("Unexpected token in statement!");
        return ParsingErrors.InvalidSyntax;
    }

    fn parse_assignement(self: *Parser) SynjErrors!*Node {
        const key_token = self.advance();
        const key_node = try nodes.create_keyword_node(self.allocator, key_token.value.sval, NodeSpan.from_token_pos(key_token.pos, key_token.pos));
        errdefer nodes.node_free(self.allocator, key_node);

        try self.expect(.EQUAL, "Expected '=' after identifier keyword");
        const value_node = self.parse_expression() catch |err| {
            nodes.node_free(self.allocator, key_node);
            return err;
        };
        const span = NodeSpan.from_token_pos(key_token.pos, TokenPos{ .line = value_node.span.end_line, .col = value_node.span.end_col });
        return nodes.create_assignment_node(self.allocator, key_node, value_node, span);
    }

    fn parse_expression(self: *Parser) SynjErrors!*Node {
        const tok = self.peek();
        switch (tok.type) {
            .STRING_LITERAL => return try self.parse_string_literal(),
            .NUMBER_LITERAL => return try self.parse_number_literal(),
            .NULL_LITERAL => return try self.parse_null_literal(),
            .LEFT_BRACKET => return try self.parse_array(),
            .LEFT_BRACE => return try self.parse_object(),
            .KEYWORD => {
                const key = self.advance();
                return nodes.create_keyword_node(self.allocator, key.value.sval, NodeSpan.from_token_pos(key.pos, key.pos));
            },
            else => {
                try self.unexpected_error("Unexpected token in expression");
                return ParsingErrors.InvalidSyntax;
            },
        }
    }

    fn parse_string_literal(self: *Parser) SynjErrors!*Node {
        const str_tok = self.advance();
        return nodes.create_string_node(self.allocator, str_tok.value.sval, NodeSpan.from_token_pos(str_tok.pos, str_tok.pos));
    }

    fn parse_number_literal(self: *Parser) SynjErrors!*Node {
        const num_tok = self.advance();
        if (num_tok.num_type == TokenNumType.TOKEN_INTEGER) {
            return nodes.create_integer_node(self.allocator, num_tok.value.inum, NodeSpan.from_token_pos(num_tok.pos, num_tok.pos));
        }

        return nodes.create_float_node(self.allocator, num_tok.value.lnum, NodeSpan.from_token_pos(num_tok.pos, num_tok.pos));
    }

    fn parse_null_literal(self: *Parser) SynjErrors!*Node {
        const null_tok = self.advance();
        return nodes.create_null_node(self.allocator, NodeSpan.from_token_pos(null_tok.pos, null_tok.pos));
    }

    fn parse_array(self: *Parser) SynjErrors!*Node {
        const start_tok = self.advance();
        var elems = std.ArrayList(*Node).init(self.allocator);
        errdefer elems.deinit();

        var last_tok = self.peek();
        if (last_tok.type != .RIGHT_BRACKET) {
            while (true) {
                const elem = try self.parse_expression();
                try elems.append(elem);
                last_tok = self.peek();
                if (!self.match(.COMMA)) break;
            }
        }

        try self.expect(.RIGHT_BRACKET, "Expected ']' after array elements");
        const span = NodeSpan.from_token_pos(start_tok.pos, last_tok.pos);
        return nodes.create_array_node(self.allocator, try elems.toOwnedSlice(), span);
    }

    fn parse_object(self: *Parser) SynjErrors!*Node {
        const start_tok = self.advance();
        var props = std.ArrayList(*Node).init(self.allocator);
        var last_tok = self.peek();
        if (last_tok.type != .RIGHT_BRACE) {
            while (true) {
                const key_tok = self.advance();
                try self.expect(.COLON, "Expected ':' after key");
                const value_node = try self.parse_expression();
                const key_value_span = NodeSpan.from_token_pos(key_tok.pos, TokenPos{ .line = value_node.span.end_line, .col = value_node.span.end_col });
                const key_value_node = try nodes.create_key_value_pair_node(self.allocator, try nodes.create_string_node(self.allocator, key_tok.value.sval, NodeSpan.from_token_pos(key_tok.pos, key_tok.pos)), value_node, key_value_span);
                try props.append(key_value_node);
                last_tok = self.peek();
                if (!self.match(.COMMA)) break;
            }
        }

        try self.expect(.RIGHT_BRACE, "Expected '}' after object literal");
        const span = NodeSpan.from_token_pos(start_tok.pos, last_tok.pos);
        return nodes.create_object_node(self.allocator, try props.toOwnedSlice(), span);
    }
};

pub fn parser_parse_body(
    allocator: std.mem.Allocator,
    buffer: []const u8,
    buffer_len: usize,
) !*Node {
    const stdout = std.io.getStdOut().writer();

    var lexer = Lexer.init(buffer, buffer_len);
    var tokenizer = Tokenizer.init(&lexer, allocator);
    defer tokenizer.deinit();
    var parser = Parser.init(&tokenizer, allocator);
    defer parser.errors.deinit();

    var root: ?*Node = null;

    root = parser.parse() catch |err| {
        for (parser.errors.items) |e| {
            try stdout.print("Syntax error at line {d}, col {d}: {s}\n", .{ e.pos.line, e.pos.col, e.message });
        }
        return err;
    };

    if (parser.errors.items.len > 0) {
        for (parser.errors.items) |e| {
            try stdout.print("Syntax error at line {d}, col {d}: {s}\n", .{ e.pos.line, e.pos.col, e.message });
        }

        if (root) |r| {
            nodes.node_free(allocator, r);
        }

        return ParsingErrors.InvalidSyntax;
    }

    return root.?;
}
