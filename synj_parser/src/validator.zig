const std = @import("std");

const synj = @import("synj.zig");
const Synj = synj.Synj;
const ModelType = synj.ModelType;
const EarlyStop = synj.EarlyStop;

const nodes = @import("node.zig");
const Node = nodes.Node;
const NodeType = nodes.NodeType;
const NumberValue = nodes.NumberValue;

pub const ValidatorError = struct {
    message: []const u8,
    field: []const u8,
    line: usize,
    col: usize,
};

pub const Validator = struct {
    allocator: std.mem.Allocator,
    errors: std.ArrayList(ValidatorError),

    // Required fields
    model_name_seen: bool = false,
    algorithm_seen: bool = false,
    csv_path_seen: bool = false,
    target_seen: bool = false,
    train_test_split_seen: bool = false,
    features_seen: bool = false,
    epochs_seen: bool = false,

    pub fn init(allocator: std.mem.Allocator) Validator {
        return Validator{
            .allocator = allocator,
            .errors = std.ArrayList(ValidatorError).init(allocator),
        };
    }

    pub fn deinit(self: *Validator) void {
        self.errors.deinit();
    }

    fn add_error(self: *Validator, field: []const u8, message: []const u8, line: usize, col: usize) !void {
        const msg = try std.fmt.allocPrint(self.allocator, "{s}: {s}", .{ field, message });
        try self.errors.append(ValidatorError{
            .message = msg,
            .field = field,
            .line = line,
            .col = col,
        });
    }

    pub fn validate(self: *Validator, root: *Node, synj_config: *Synj) !bool {
        if (root.node_type != .Program) {
            try self.add_error("root", "Root node must be a program", 0, 0);
            return false;
        }

        // Process all assignments
        for (root.value.Program.stmts) |stmt| {
            try self.validate_assignment(stmt, synj_config);
        }

        // Check if all required fields are present
        if (!self.model_name_seen) {
            try self.add_error("model_name", "Required field is missing", 0, 0);
        }

        if (!self.algorithm_seen) {
            try self.add_error("algorithm", "Required field is missing", 0, 0);
        }

        if (!self.csv_path_seen) {
            try self.add_error("csv_path", "Required field is missing for input data", 0, 0);
        }

        if (!self.target_seen) {
            try self.add_error("target", "Required field is missing", 0, 0);
        }

        if (!self.train_test_split_seen) {
            try self.add_error("train_test_split", "Required field is missing", 0, 0);
        }

        if (!self.features_seen) {
            try self.add_error("features", "Required field is missing", 0, 0);
        }

        if (!self.epochs_seen) {
            try self.add_error("epochs", "Required field is missing", 0, 0);
        }

        return self.errors.items.len == 0;
    }

    fn validate_assignment(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .Assignment) {
            try self.add_error("statement", "Expected assignment", node.span.start_line, node.span.start_col);
            return;
        }

        const key_node = node.value.Assignment.name;
        const value_node = node.value.Assignment.value;

        if (key_node.node_type != .Keyword) {
            try self.add_error("assignment", "Key must be a keyword", node.span.start_line, node.span.start_col);
            return;
        }

        const key = key_node.value.Keyword;

        // Validate based on the key name and rules
        if (std.mem.eql(u8, key, "model_name")) {
            self.model_name_seen = true;
            try self.validate_model_name(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "algorithm")) {
            self.algorithm_seen = true;
            try self.validate_model_type(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "csv_path")) {
            self.csv_path_seen = true;
            try self.validate_csv_path(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "target")) {
            self.target_seen = true;
            try self.validate_target(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "train_test_split")) {
            self.train_test_split_seen = true;
            try self.validate_train_test_split(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "features")) {
            self.features_seen = true;
            try self.validate_features(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "classes")) {
            try self.validate_classes(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "epochs")) {
            self.epochs_seen = true;
            try self.validate_epochs(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "learning_rate")) {
            try self.validate_learning_rate(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "batch_size")) {
            try self.validate_batch_size(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "early_stop")) {
            try self.validate_early_stop(value_node, synj_config);
        } else if (std.mem.eql(u8, key, "output_path")) {
            try self.validate_output_path(value_node, synj_config);
        } else {
            try self.add_error(key, "Unknown field", node.span.start_line, node.span.start_col);
        }
    }

    fn validate_model_name(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .StringLiteral) {
            try self.add_error("model_name", "Model Name must be a string", node.span.start_line, node.span.start_col);
            return;
        }

        synj_config.model_name = (try self.allocator.dupeZ(u8, node.value.StringLiteral)).ptr;
    }

    fn validate_model_type(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .Keyword) {
            try self.add_error("algorithm", "Must be a keyword (LinearRegression or LogisticRegression)", node.span.start_line, node.span.start_col);
            return;
        }

        const value = node.value.Keyword;
        if (std.mem.eql(u8, value, "LinearRegression")) {
            synj_config.model_type = ModelType.LinearRegression;
        } else if (std.mem.eql(u8, value, "LogisticRegression")) {
            synj_config.model_type = ModelType.LogisticRegression;
        } else {
            try self.add_error("algorithm", "Must be either LinearRegression or LogisticRegression", node.span.start_line, node.span.start_col);
        }
    }

    fn validate_csv_path(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .StringLiteral) {
            try self.add_error("csv_path", "Path must be a string", node.span.start_line, node.span.start_col);
            return;
        }

        synj_config.csv_path = (try self.allocator.dupeZ(u8, node.value.StringLiteral)).ptr;
    }

    fn validate_target(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .StringLiteral) {
            try self.add_error("target", "Must be a string (column name)", 0, 0);
            return;
        }

        synj_config.target = (try self.allocator.dupeZ(u8, node.value.StringLiteral)).ptr;
    }

    fn validate_train_test_split(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .ArrayLiteral) {
            try self.add_error("train_test_split", "Must be an array", node.span.start_line, node.span.start_col);
            return;
        }

        const array = node.value.ArrayLiteral.elems;
        if (array.len != 2) {
            try self.add_error("train_test_split", "Must contain exactly 2 inetgers", node.span.start_line, node.span.start_col);
            return;
        }

        for (array, 0..) |elem, idx| {
            if (elem.node_type != .NumberLiteral or std.meta.activeTag(elem.value.NumberLiteral) != .Int) {
                try self.add_error("train_test_split", "Array elements must be integers", node.span.start_line, node.span.start_col);
                return;
            }

            synj_config.train_test_split[idx] = @intCast(elem.value.NumberLiteral.Int);
        }

        // Check sum is 100
        const sum = synj_config.train_test_split[0] + synj_config.train_test_split[1];
        if (sum != 100) {
            try self.add_error("train_test_split", "Values must sum to 100", node.span.start_line, node.span.start_col);
        }
    }

    fn validate_features(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .ArrayLiteral) {
            try self.add_error("features", "Must be an array of strings", node.span.start_line, node.span.start_col);
            return;
        }

        const array = node.value.ArrayLiteral.elems;
        if (array.len == 0) {
            try self.add_error("features", "Cannot be empty", node.span.start_line, node.span.start_col);
            return;
        }

        var features = try self.allocator.alloc([*:0]u8, array.len);

        // Check all features are string
        for (array, 0..) |elem, idx| {
            if (elem.node_type != .StringLiteral) {
                try self.add_error("features", "Array elements must be strings", elem.span.start_line, elem.span.start_col);

                // Free what we've already allocated
                for (0..idx) |j| {
                    self.allocator.free(std.mem.span(features[j]));
                }
                self.allocator.free(features);
                return;
            }

            features[idx] = (try self.allocator.dupeZ(u8, elem.value.StringLiteral)).ptr;
        }

        synj_config.features = features.ptr;
    }

    fn validate_classes(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type == .NullLiteral) {
            synj_config.classes = null;
            return;
        }

        if (node.node_type != .ArrayLiteral) {
            try self.add_error("classes", "Must be an array of string or NULL", node.span.start_line, node.span.start_col);
            return;
        }

        const array = node.value.ArrayLiteral.elems;
        if (array.len == 0) {
            synj_config.classes = null;
            return;
        }

        var classes = try self.allocator.alloc([*:0]u8, array.len);

        // Check all elements are string
        for (array, 0..) |elem, idx| {
            if (elem.node_type != .StringLiteral) {
                try self.add_error("classes", "Array elements must be strings", node.span.start_line, node.span.start_col);

                // Free what we've already allocated
                for (0..idx) |j| {
                    self.allocator.free(std.mem.span(classes[j]));
                }
                self.allocator.free(classes);
                return;
            }

            classes[idx] = (try self.allocator.dupeZ(u8, elem.value.StringLiteral)).ptr;
        }

        synj_config.classes = classes.ptr;
    }

    fn validate_epochs(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type != .NumberLiteral or std.meta.activeTag(node.value.NumberLiteral) != .Int) {
            try self.add_error("epochs", "Must be an integer", node.span.start_line, node.span.start_col);
            return;
        }

        const value = node.value.NumberLiteral.Int;
        if (value < 2) {
            try self.add_error("epochs", "Must be at least 2", node.span.start_line, node.span.start_col);
            return;
        }

        if (value > std.math.maxInt(u32)) {
            try self.add_error("epochs", "Value too large", node.span.start_line, node.span.start_col);
            return;
        }

        synj_config.epochs = @intCast(value);
    }

    fn validate_learning_rate(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type == .NullLiteral) {
            return;
        }

        if (node.node_type != .NumberLiteral or std.meta.activeTag(node.value.NumberLiteral) != .Float) {
            try self.add_error("learning_rate", "Must be Null or Float", node.span.start_line, node.span.start_col);
            return;
        }

        synj_config.learning_rate = node.value.NumberLiteral.Float;
    }

    fn validate_batch_size(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type == .NullLiteral) {
            synj_config.batch_size = null;
            return;
        }

        if (node.node_type != .NumberLiteral or std.meta.activeTag(node.value.NumberLiteral) != .Int) {
            try self.add_error("batch_size", "Must be an integer or null", node.span.start_line, node.span.start_col);
            return;
        }

        const value = node.value.NumberLiteral.Int;
        if (value <= 0) {
            try self.add_error("batch_size", "Must be a positive integer", node.span.start_line, node.span.start_col);
            return;
        }

        if (value > std.math.maxInt(u32)) {
            try self.add_error("batch_size", "Value too large", node.span.start_line, node.span.start_col);
            return;
        }

        synj_config.batch_size = @intCast(value);
    }

    fn validate_early_stop(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type == .NullLiteral) {
            synj_config.early_stop = null;
            return;
        }

        if (node.node_type != .ObjectLiteral) {
            try self.add_error("early_stop", "Must be an object or null", node.span.start_line, node.span.start_col);
            return;
        }

        const props = node.value.ObjectLiteral.props;
        if (props.len != 1) {
            try self.add_error("early_stop", "Must have exactly one property 'patience'", node.span.start_line, node.span.start_col);
            return;
        }

        const prop = props[0];
        if (prop.node_type != .KeyValuePair) {
            try self.add_error("early_stop", "Invalid object property", node.span.start_line, node.span.start_col);
            return;
        }

        const key_node = prop.value.KeyValuePair.key;
        const value_node = prop.value.KeyValuePair.value;

        if (key_node.node_type != .StringLiteral or !std.mem.eql(u8, key_node.value.StringLiteral, "patience")) {
            try self.add_error("early_stop", "Must have a property named 'patience'", node.span.start_line, node.span.start_col);
            return;
        }

        if (value_node.node_type != .NumberLiteral or std.meta.activeTag(value_node.value.NumberLiteral) != .Int) {
            try self.add_error("early_stop.patience", "Must be an integer", value_node.span.start_line, value_node.span.start_col);
            return;
        }

        const patience_value = value_node.value.NumberLiteral.Int;
        if (patience_value <= 0) {
            try self.add_error("early_stop.patience", "Must be a positive integer", value_node.span.start_line, value_node.span.start_col);
            return;
        }

        if (patience_value > std.math.maxInt(u32)) {
            try self.add_error("early_stop.patience", "Value too large", value_node.span.start_line, value_node.span.start_col);
            return;
        }

        if (self.epochs_seen and patience_value >= synj_config.epochs) {
            try self.add_error("early_stop.patience", "Must be less than epochs", value_node.span.start_line, value_node.span.start_col);
            return;
        }

        synj_config.early_stop = EarlyStop{ .patience = @intCast(patience_value) };
    }

    fn validate_output_path(self: *Validator, node: *Node, synj_config: *Synj) !void {
        if (node.node_type == .NullLiteral) {
            return;
        }

        if (node.node_type != .StringLiteral) {
            try self.add_error("output_path", "Must be a string or null", node.span.start_line, node.span.start_col);
            return;
        }

        // Free default value first
        if (synj_config.output_path != null) {
            self.allocator.free(std.mem.span(synj_config.output_path.?));
        }

        synj_config.output_path = (try self.allocator.dupeZ(u8, node.value.StringLiteral)).ptr;
    }
};

pub fn validate_ast(allocator: std.mem.Allocator, root_node: *Node, synj_config: *Synj) !bool {
    var validator = Validator.init(allocator);
    defer validator.deinit();

    const is_valid_ast = try validator.validate(root_node, synj_config);
    if (!is_valid_ast) {
        const stderr = std.io.getStdErr().writer();
        try stderr.print("\n--- Validation Errors ---\n", .{});
        for (validator.errors.items) |err| {
            try stderr.print("Error at line {d}, col {d}: {s}\n", .{ err.line, err.col, err.message });
        }
        try stderr.print("-------------------------\n\n", .{});
    }

    if (synj_config.output_path == null) {
        synj_config.output_path = (try allocator.dupeZ(u8, "model/model.json")).ptr;
    }

    return is_valid_ast;
}
