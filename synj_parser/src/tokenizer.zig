// tokenizer.zig - SYNJ Tokenizer structure definition and functions
//
// This file defines structures and implements functions related to
// the SYNJ DSL to be parsed for the model configuration
//
// Author: Fedi Nabli
// Date: 15 May 2025
// Last Modified: 15 May 2025

const std = @import("std");

const helper = @import("helper.zig");

const Lexer = @import("lexer.zig").Lexer;

const TokenizerErrors = @import("error.zig").TokenizerErrors;

pub const TokenType = enum {
    KEYWORD,
    NULL_LITERAL,
    STRING_LITERAL,
    NUMBER_LITERAL,
    SEMICOLON,
    COLON,
    EQUAL,
    COMMA,
    LEFT_BRACKET,
    RIGHT_BRACKET,
    LEFT_BRACE,
    RIGHT_BRACE,
    EOF,
};

pub const TokenNumType = enum {
    TOKEN_INTEGER,
    TOKEN_FLOAT,
};

pub const TokenPos = struct {
    line: usize,
    col: usize,
};

pub const TokenVal = union {
    cval: u8,
    sval: []const u8,
    inum: u64,
    lnum: f64,
};

pub const Token = struct {
    type: TokenType,
    pos: TokenPos,
    value: TokenVal,
    num_type: ?TokenNumType,
    lexeme: []const u8,

    pub fn token_is_keyword(token: *Token, value: []const u8) bool {
        return token and token.type == TokenType.KEYWORD and std.mem.eql(u8, token.value.sval, value);
    }
};

pub const Tokenizer = struct {
    lex: *Lexer,
    peek: ?Token,
    allocator: std.mem.Allocator,

    pub fn init(lexer_ptr: *Lexer, allocator: std.mem.Allocator) Tokenizer {
        return Tokenizer{
            .lex = lexer_ptr,
            .peek = null,
            .allocator = allocator,
        };
    }

    pub fn peek_token(self: *Tokenizer) !Token {
        // If we haven't peeked yet, scan the next token
        if (self.peek == null) {
            self.peek = try self.scan_token();
        }

        return self.peek.?;
    }

    pub fn next_token(self: *Tokenizer) !Token {
        // If we have a peek token, we return it
        if (self.peek != null) {
            const token = self.peek.?;
            self.peek = null;
            return token;
        }

        // Otherwise, scan a new token
        return self.scan_token();
    }

    pub fn scan_token(self: *Tokenizer) !Token {
        // Skip whitespace and comments
        self.lex.skip_whitespaces_and_comments();

        // Check for EOF
        if (self.lex.is_at_end()) {
            return create_eof_token(self.lex.line, self.lex.col);
        }

        // Get starting position for error reporting
        const start_pos = TokenPos{ .line = self.lex.line, .col = self.lex.col };
        const start_idx = self.lex.pos;

        // Get current character
        const c: u8 = self.lex.peek();

        // Handle single characters tokens
        switch (c) {
            ';' => {
                _ = self.lex.advance();
                return create_semicolon_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            ':' => {
                _ = self.lex.advance();
                return create_colon_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            ',' => {
                _ = self.lex.advance();
                return create_comma_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            '=' => {
                _ = self.lex.advance();
                return create_equal_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            '[' => {
                _ = self.lex.advance();
                return create_left_bracket_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            ']' => {
                _ = self.lex.advance();
                return create_right_bracket_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            '{' => {
                _ = self.lex.advance();
                return create_left_brace_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            '}' => {
                _ = self.lex.advance();
                return create_right_brace_token(start_pos, c, self.lex.buffer[start_idx..self.lex.pos]);
            },
            '"' => return try self.scan_string(start_pos, start_idx),
            '0'...'9' => return try self.scan_number(start_pos, start_idx),
            'a'...'z', 'A'...'Z', '_' => return try self.scan_keyword(start_pos, start_idx),
            else => return TokenizerErrors.UnexpectedCharacter,
        }
    }

    pub fn scan_string(self: *Tokenizer, start_pos: TokenPos, start_idx: usize) !Token {
        // Skip opening quote
        _ = self.lex.advance();

        var value = std.ArrayList(u8).init(self.allocator);
        defer value.deinit();

        while (!self.lex.is_at_end() and self.lex.peek() != '"') {
            var c = self.lex.peek();

            // Handle escape sequences
            if (c == '\\') {
                _ = self.lex.advance();

                if (self.lex.is_at_end()) {
                    return TokenizerErrors.UnterminatedString;
                }

                c = self.lex.peek();
                switch (c) {
                    'n' => try value.append('\n'),
                    'r' => try value.append('\r'),
                    't' => try value.append('\t'),
                    '\\' => try value.append('\\'),
                    '"' => try value.append('"'),
                    else => try value.append(c),
                }

                // Advance past the escaped character
                _ = self.lex.advance();
            } else {
                try value.append(c);
                _ = self.lex.advance();
            }
        }

        // Check for closing quote
        if (self.lex.is_at_end() or self.lex.peek() != '"') {
            return TokenizerErrors.UnterminatedString;
        }

        // Skip closing quote
        _ = self.lex.advance();

        // Create Token
        return Token{
            .type = .STRING_LITERAL,
            .pos = start_pos,
            .value = TokenVal{ .sval = try self.allocator.dupe(u8, value.items) },
            .num_type = null,
            .lexeme = self.lex.buffer[start_idx..self.lex.pos],
        };
    }

    fn scan_number(self: *Tokenizer, start_pos: TokenPos, start_idx: usize) !Token {
        var is_float = false;

        // Scan integerpart
        while (!self.lex.is_at_end() and helper.is_digit(self.lex.peek())) {
            _ = self.lex.advance();
        }

        // Look for decimal point
        if (!self.lex.is_at_end() and self.lex.peek() == '.') {
            // Check if next character is a digit
            if (!self.lex.is_at_end() and helper.is_digit(self.lex.peek_at(1))) {
                is_float = true;
                // Consume decimal point
                _ = self.lex.advance();

                // Scan the fractional part
                while (!self.lex.is_at_end() and helper.is_digit(self.lex.peek())) {
                    _ = self.lex.advance();
                }
            }
        }

        // Get the number string
        const number_str = self.lex.buffer[start_idx..self.lex.pos];

        if (is_float) {
            // Parse as float
            const value = try std.fmt.parseFloat(f64, number_str);
            return Token{
                .type = .NUMBER_LITERAL,
                .pos = start_pos,
                .value = TokenVal{ .lnum = value },
                .num_type = .TOKEN_FLOAT,
                .lexeme = number_str,
            };
        } else {
            // Parse as integer
            const value = try std.fmt.parseInt(u64, number_str, 10);
            return Token{
                .type = .NUMBER_LITERAL,
                .pos = start_pos,
                .value = TokenVal{ .inum = value },
                .num_type = .TOKEN_INTEGER,
                .lexeme = number_str,
            };
        }
    }

    pub fn scan_keyword(self: *Tokenizer, start_pos: TokenPos, start_idx: usize) !Token {
        // Scan identifier characters
        while (!self.lex.is_at_end() and helper.is_keyword_char(self.lex.peek())) {
            _ = self.lex.advance();
        }

        const keyword = self.lex.buffer[start_idx..self.lex.pos];

        // Check for NULL literal
        if (std.mem.eql(u8, keyword, "NULL")) {
            return Token{
                .type = .NULL_LITERAL,
                .pos = start_pos,
                .value = TokenVal{ .cval = 'N' },
                .num_type = null,
                .lexeme = keyword,
            };
        }

        return Token{
            .type = .KEYWORD,
            .pos = start_pos,
            .value = TokenVal{ .sval = try self.allocator.dupe(u8, keyword) },
            .num_type = null,
            .lexeme = keyword,
        };
    }

    pub fn tokenize(self: *Tokenizer) ![]Token {
        var tokens = std.ArrayList(Token).init(self.allocator);
        defer tokens.deinit();

        while (true) {
            const token = try self.next_token();
            try tokens.append(token);

            if (token.type == .EOF) {
                break;
            }
        }

        return tokens.toOwnedSlice();
    }
};

fn create_semicolon_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .SEMICOLON,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_colon_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .COLON,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_comma_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .COMMA,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_equal_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .EQUAL,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_left_bracket_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .LEFT_BRACKET,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_right_bracket_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .RIGHT_BRACKET,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_left_brace_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .LEFT_BRACE,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_right_brace_token(start_pos: TokenPos, char: u8, lexeme: []const u8) Token {
    return Token{
        .type = .RIGHT_BRACE,
        .pos = start_pos,
        .value = TokenVal{ .cval = char },
        .num_type = null,
        .lexeme = lexeme,
    };
}

fn create_eof_token(line: usize, col: usize) Token {
    return Token{
        .type = .EOF,
        .pos = TokenPos{ .line = line, .col = col },
        .value = TokenVal{ .cval = 0 },
        .num_type = null,
        .lexeme = "",
    };
}
