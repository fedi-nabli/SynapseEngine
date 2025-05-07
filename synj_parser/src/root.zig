const std = @import("std");
const testing = std.testing;

pub export fn add_synj(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add_synj(3, 7) == 10);
}
