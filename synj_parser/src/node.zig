// node.zig - SYNJ AST Node definitions
//
// This file defines structures acting as an IR
// and implements functions related to
// the SYNJ DSL to be parsed for the model configuration
//
// Author: Fedi Nabli
// Date: 16 May 2025
// Last Modified: 16 May 2025

const std = @import("std");

const TokenPos = @import("tokenizer.zig").TokenPos;

pub const NodeType = enum {
    Program,
    Assignment,
    Keyword,
    NullLiteral,
    StringLiteral,
    NumberLiteral,
    ArrayLiteral,
    ObjectLiteral,
    KeyValuePair,
};

pub const NodeSpan = struct {
    start_line: usize,
    start_col: usize,
    end_line: usize,
    end_col: usize,

    pub fn from_token_pos(start_pos: TokenPos, end_pos: TokenPos) NodeSpan {
        return NodeSpan{
            .start_line = start_pos.line,
            .start_col = start_pos.col,
            .end_line = end_pos.line,
            .end_col = end_pos.col,
        };
    }
};

pub const NumberValue = union(enum) {
    Int: u64,
    Float: f64,
};

pub const NodeValue = union(NodeType) {
    Program: struct { stmts: []*Node },
    Assignment: struct { name: *Node, value: *Node },
    Keyword: []const u8,
    NullLiteral: void,
    StringLiteral: []const u8,
    NumberLiteral: NumberValue,
    ArrayLiteral: struct { elems: []*Node },
    ObjectLiteral: struct { props: []*Node },
    KeyValuePair: struct { key: *Node, value: *Node },
};

pub const Node = struct {
    node_type: NodeType,
    value: NodeValue,
    span: NodeSpan,

    pub fn children(self: *const Node) []*Node {
        return switch (self.value) {
            .Program => self.value.Program.stmts,
            .Assignment => &[_]*Node{ self.value.Assignment.name, self.value.Assignment.value },
            .ArrayLiteral => self.value.ArrayLiteral.elems,
            .ObjectLiteral => self.value.ObjectLiteral.props,
            .KeyValuePair => &[_]*Node{ self.value.KeyValuePair.key, self.value.KeyValuePair.value },
            else => &[_]*Node{},
        };
    }

    pub fn is_type(self: *const Node, t: NodeType) bool {
        return self.node_type == t;
    }

    pub fn is_literal(self: *const Node) bool {
        return switch (self.node_type) {
            .StringLiteral, .NumberLiteral, .NullLiteral => true,
            else => false,
        };
    }

    pub fn get_number_type(self: *const Node) ?std.meta.Tag(NumberValue) {
        if (self.node_type != .NUMBER_LITERAL) return null;
        return std.meta.activeTag(self.value.NumberLiteral);
    }

    pub fn is_integer(self: *const Node) bool {
        return self.get_number_type() == .Int;
    }

    pub fn is_float(self: *const Node) bool {
        return self.get_number_type() == .Float;
    }

    pub fn get_keyword(self: *const Node) ?[]const u8 {
        if (self.node_type != .KEYWORD) return null;
        return self.value.Keyword;
    }

    pub fn get_string(self: *const Node) ?[]const u8 {
        if (self.node_type != .STRING_LITERAL) return null;
        return self.value.StringLiteral;
    }
};

pub fn create_program_node(allocator: std.mem.Allocator, stmts: []*Node, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .Program,
        .span = span,
        .value = NodeValue{ .Program = .{ .stmts = stmts } },
    };
    return node;
}

pub fn create_assignment_node(allocator: std.mem.Allocator, name: *Node, value: *Node, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .Assignment,
        .span = span,
        .value = NodeValue{ .Assignment = .{ .name = name, .value = value } },
    };
    return node;
}

pub fn create_keyword_node(allocator: std.mem.Allocator, name: []const u8, span: NodeSpan) !*Node {
    const name_copy = try allocator.dupe(u8, name);
    errdefer allocator.free(name_copy);

    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .Keyword,
        .span = span,
        .value = NodeValue{ .Keyword = name_copy },
    };
    return node;
}

pub fn create_null_node(allocator: std.mem.Allocator, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .NullLiteral,
        .span = span,
        .value = NodeValue{ .NullLiteral = {} },
    };
    return node;
}

pub fn create_string_node(allocator: std.mem.Allocator, str: []const u8, span: NodeSpan) !*Node {
    const str_copy = try allocator.dupe(u8, str);
    errdefer allocator.free(str_copy);

    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .StringLiteral,
        .span = span,
        .value = NodeValue{ .StringLiteral = str_copy },
    };
    return node;
}

pub fn create_number_node(allocator: std.mem.Allocator, num: NumberValue, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .NumberLiteral,
        .span = span,
        .value = NodeValue{ .NumberLiteral = num },
    };
    return node;
}

pub fn create_integer_node(allocator: std.mem.Allocator, value: u64, span: NodeSpan) !*Node {
    return create_number_node(allocator, NumberValue{ .Int = value }, span);
}

pub fn create_float_node(allocator: std.mem.Allocator, value: f64, span: NodeSpan) !*Node {
    return create_number_node(allocator, NumberValue{ .Float = value }, span);
}

pub fn create_array_node(allocator: std.mem.Allocator, elems: []*Node, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .ArrayLiteral,
        .span = span,
        .value = NodeValue{ .ArrayLiteral = .{ .elems = elems } },
    };
    return node;
}

pub fn create_object_node(allocator: std.mem.Allocator, props: []*Node, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .ObjectLiteral,
        .span = span,
        .value = NodeValue{ .ObjectLiteral = .{ .props = props } },
    };
    return node;
}

pub fn create_key_value_pair_node(allocator: std.mem.Allocator, key: *Node, value: *Node, span: NodeSpan) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .node_type = .KeyValuePair,
        .span = span,
        .value = NodeValue{ .KeyValuePair = .{ .key = key, .value = value } },
    };
    return node;
}

pub fn node_free(allocator: std.mem.Allocator, node: *Node) void {
    switch (node.node_type) {
        .Program => {
            for (node.value.Program.stmts) |stmt| {
                node_free(allocator, stmt);
            }
            allocator.free(node.value.Program.stmts);
        },
        .Assignment => {
            node_free(allocator, node.value.Assignment.name);
            node_free(allocator, node.value.Assignment.value);
        },
        .KeyValuePair => {
            node_free(allocator, node.value.KeyValuePair.key);
            node_free(allocator, node.value.KeyValuePair.value);
        },
        .ArrayLiteral => {
            for (node.value.ArrayLiteral.elems) |elem| {
                node_free(allocator, elem);
            }
            allocator.free(node.value.ArrayLiteral.elems);
        },
        .ObjectLiteral => {
            for (node.value.ObjectLiteral.props) |prop| {
                node_free(allocator, prop);
            }
            allocator.free(node.value.ObjectLiteral.props);
        },
        .Keyword => {
            allocator.free(node.value.Keyword);
        },
        .StringLiteral => {
            allocator.free(node.value.StringLiteral);
        },
        .NullLiteral => {},
        .NumberLiteral => {},
    }

    allocator.destroy(node);
}
