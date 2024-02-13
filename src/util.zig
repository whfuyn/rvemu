const std = @import("std");
const panic = std.debug.panic;

pub fn fatal(msg: []const u8) void {
    panic("FATAL: {s}\n", msg);
}
