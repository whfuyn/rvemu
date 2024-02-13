const std = @import("std");
const mmu = @import("mmu.zig");
const toHost = mmu.toHost;
const toGuest = mmu.toGuest;
const decode = @import("decode.zig");
const machine = @import("machine.zig");
const Instruction = decode.Instruction;
const InsnType = decode.InsnType;
const State = machine.State;

const INSTR_HANDLERS = [_]fn (*State, *const Instruction) callconv(.Inline) void{
    addi,
};

inline fn addi(state: *State, insn: *const Instruction) void {
    _ = state;
    _ = insn;
    unreachable;
}

pub fn executeBlockInterp(state: *State) void {
    var insn: Instruction = undefined;
    while (true) {
        // TODO: will it cause problems if it's a compressed insnuction?
        const pc: *const u32 = @ptrFromInt(toHost(state.pc));
        const insn_word = pc.*;
        insn = Instruction.decode(insn_word);

        switch (@intFromEnum(insn.ty)) {
            inline @intFromEnum(InsnType.addi)...@intFromEnum(InsnType.addi) => |idx| INSTR_HANDLERS[idx](state, &insn),
            else => unreachable,
        }

        state.gp_regs[@intFromEnum(decode.GpReg.zero)] = 0;

        if (insn.cont) break;

        state.pc += if (insn.rvc) 2 else 4;
    }
}
