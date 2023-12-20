const Mmu = @import("mmu.zig").Mmu;

const State = struct {
    gp_regs: [32]u64,
    pc: u64,
};

const Machine = struct {
    state: State = undefined,
    mmu: Mmu = .{},

    fn load_program(self: *Machine) void {
        _ = self;
    }
};
