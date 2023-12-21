const std = @import("std");
const mmu = @import("mmu.zig");
const toHost = mmu.toHost;
const toGuest = mmu.toGuest;
const decode = @import("decode.zig");
const machine = @import("machine.zig");
const Instruction = decode.Instruction;
const State = machine.State;

// TODO: How can I `#[zigfmt(skip)]` it?
const GpReg = enum(u5) {
    zero,
    ra,
    sp,
    gp,
    tp,
    //
    t0,
    t1,
    t2,
    //
    s0,
    s1,
    //
    a0,
    a1,
    a2,
    a3,
    a4,
    a5,
    a6,
    a7,
    //
    s2,
    s3,
    s4,
    s5,
    s6,
    s7,
    s8,
    s9,
    s10,
    s11,
    //
    t3,
    t4,
    t5,
    t6,
};

// TODO: how can I get it inline?
const INSTR_HANDLER = [_]*const fn (*State, *const Instruction) void{addi};

fn addi(state: *State, instr: *const Instruction) void {
    _ = state;
    _ = instr;
    unreachable;
}

pub fn executeBlockInterp(state: *State) void {
    var instr: Instruction = undefined;
    while (true) {
        const pc: *const u32 = @ptrFromInt(toHost(state.pc));
        const instr_word = pc.*;
        instr = Instruction.decode(u32, instr_word);

        const index = @intFromEnum(instr.ty);
        INSTR_HANDLER[index](state, &instr);

        state.gp_regs[@intFromEnum(GpReg.zero)] = 0;

        if (instr.cont) break;

        state.pc += if (instr.rvc) 2 else 4;
    }
}
