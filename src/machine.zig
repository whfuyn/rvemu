const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const elf = @import("elf.zig");
const Mmu = @import("mmu.zig").Mmu;
const assert = std.debug.assert;
const interp = @import("interp.zig");

const ExitReason = enum {
    none,
    direct_branch,
    indirect_branch,
    ecall,
};

pub const State = struct {
    gp_regs: [32]u64 = [1]u64{0} ** 32,
    pc: u64 = 0,

    exit_reason: ExitReason = ExitReason.none,
};

pub const Machine = struct {
    state: State = .{},
    mmu: Mmu = .{},

    pub fn load_program(self: *Machine, file_path: [:0]const u8, allocator: mem.Allocator) !void {
        var f = try fs.cwd().openFile(file_path, .{});
        defer f.close();

        const stat = try f.stat();
        const elf_bytes = try allocator.alignedAlloc(u8, @alignOf(elf.Elf64Ehdr), stat.size);
        defer allocator.free(elf_bytes);

        const bytes_read = try f.readAll(elf_bytes);
        assert(bytes_read == stat.size);

        try self.mmu.loadElf(elf_bytes);
        self.state.pc = self.mmu.entry;
    }

    pub fn step(self: *Machine) void {
        while (true) {
            interp.executeBlockInterp(&self.state);

            if (self.state.exit_reason == .direct_branch or self.state.exit_reason == .indirect_branch) {
                continue;
            }
            break;
        }

        assert(self.state.exit_reason == .ecall);
    }
};
