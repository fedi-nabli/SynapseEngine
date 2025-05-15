// lexer.zig - SYNJ Lexer structure definition and functions
//
// This file defines structures and implements functions related to
// the SYNJ DSL to be parsed for the model configuration
//
// Author: Fedi Nabli
// Date: 14 May 2025
// Last Modified: 15 May 2025

pub const Position = struct {
    line: usize,
    col: usize,
};

pub const Span = struct {
    start: Position,
    end: Position,
};

pub const Lexer = struct {
    buffer: []const u8,
    buffer_len: usize,
    pos: usize,
    line: usize,
    col: usize,

    pub fn init(buffer: []const u8, len: usize) Lexer {
        return Lexer{
            .buffer = buffer,
            .buffer_len = len,
            .pos = 0,
            .line = 1,
            .col = 1,
        };
    }

    pub fn peek(self: *Lexer) u8 {
        if (self.pos >= self.buffer_len)
            return 0;

        return self.buffer[self.pos];
    }

    pub fn peek_at(self: *Lexer, pos_ahead: usize) u8 {
        if (self.pos + pos_ahead >= self.buffer_len)
            return 0;

        return self.buffer[self.pos + pos_ahead];
    }

    pub fn advance(self: *Lexer) u8 {
        if (self.pos >= self.buffer_len)
            return 0;

        const char: u8 = self.buffer[self.pos];

        self.pos += 1;
        self.col += 1;

        if (char == '\n') {
            self.line += 1;
            self.col = 1;
        }

        return char;
    }

    pub fn is_at_end(self: *Lexer) bool {
        if (self.pos >= self.buffer_len)
            return true;

        return false;
    }

    pub fn read_until_end(self: *Lexer) void {
        while (self.pos < self.buffer_len) {
            if (peek(self) == '\n')
                break;

            _ = advance(self);
        }
    }

    pub fn skip_whitespaces(self: *Lexer) void {
        while (!is_at_end(self)) {
            const c = peek(self);
            if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
                _ = advance(self);
            } else {
                break;
            }
        }
    }

    pub fn skip_comment(self: *Lexer) void {
        if (peek(self) == '/' and peek_at(self, 1) == '/') {
            _ = advance(self);
            _ = advance(self);
            read_until_end(self);
            if (peek(self) == '\n')
                _ = advance(self);
        }
    }

    pub fn skip_whitespaces_and_comments(self: *Lexer) void {
        while (true) {
            skip_whitespaces(self);
            if (peek(self) == '/' and peek_at(self, 1) == '/') {
                skip_comment(self);
                continue;
            } else {
                break;
            }
        }
    }

    pub fn match(self: *Lexer, expected: u8) bool {
        if (peek(self) == expected) {
            _ = advance(self);
            return true;
        }

        return false;
    }

    pub fn get_position(self: *Lexer) Position {
        return Position{ .line = self.line, .col = self.col };
    }

    pub fn make_span(self: *Lexer, start: Position) Span {
        return Span{ .start = start, .end = get_position(self) };
    }
};
