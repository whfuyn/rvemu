const std = @import("std");
const os = std.os;
const mmu = @import("mmu.zig");
const elf = @import("elf.zig");
const assert = std.debug.assert;
const fs = std.fs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var f = try fs.cwd().openFile("example", .{});
    defer f.close();

    const stat = try f.stat();
    const buf = try allocator.alignedAlloc(u8, @alignOf(elf.Elf64Ehdr), stat.size);
    defer allocator.free(buf);

    const bytes_read = try f.readAll(buf);
    assert(bytes_read == stat.size);

    var m = mmu.Mmu{};
    try m.loadElf(buf);

    // const buf: [:0]u8 = try allocator.allocSentinel(u8, stat.size, 0);
    // defer allocator.free(buf);

    // assert(try f.readAll(buf) == stat.size);

    // std.debug.print("{s}", .{buf});
}
