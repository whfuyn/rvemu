const std = @import("std");
const util = @import("util.zig");
const fatal = util.fatal;
const assert = std.debug.assert;

// It tells which quadrant is this insnuction
inline fn QUADRANT(data: u32) InsnQuadrant {
    return @enumFromInt(data & 0x3);
}

inline fn OPCODE(data: u32) u32 {
    return (data >> 2) & 0x1f;
}

inline fn RD(data: u32) GpReg {
    return @enumFromInt((data >> 7) & 0x1f);
}

inline fn RS1(data: u32) GpReg {
    return @enumFromInt((data >> 15) & 0x1f);
}

inline fn RS2(data: u32) GpReg {
    return @enumFromInt((data >> 20) & 0x1f);
}

inline fn RS3(data: u32) GpReg {
    return @enumFromInt((data >> 27) & 0x1f);
}

inline fn FUNCT2(data: u32) u32 {
    return (data >> 25) & 0x3;
}

inline fn FUNCT3(data: u32) u32 {
    return (data >> 12) & 0x7;
}

inline fn FUNCT7(data: u32) u32 {
    return (data >> 25) & 0x7f;
}

// 116 means IMM[11:6], i.e. bits 6-11 of the immediate
inline fn IMM116(data: u32) u32 {
    return (data >> 25) & 0x3f;
}

inline fn COPCODE(data: u32) u32 {
    return (data >> 13) & 0x7;
}

inline fn CFUNCT1(data: u32) u32 {
    return (data >> 12) & 0x1;
}

inline fn CFUNCT2LOW(data: u32) u32 {
    return (data >> 5) & 0x3;
}

inline fn CFUNCT2HIGH(data: u32) u32 {
    return (data >> 10) & 0x3;
}

inline fn RP1(data: u32) u32 {
    return (data >> 7) & 0x7;
}

inline fn RP2(data: u32) u32 {
    return (data >> 2) & 0x7;
}

inline fn RC1(data: u32) GpReg {
    return @enumFromInt((data >> 7) & 0x1f);
}

inline fn RC2(data: u32) GpReg {
    return @enumFromInt((data >> 2) & 0x1f);
}

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

const InsnQuadrant = enum(u2) {
    Q0,
    Q1,
    Q2,
    Q3,
};

pub const InsnType = enum(u32) {
    lb,
    lh,
    lw,
    ld,
    lbu,
    lhu,
    lwu,
    fence,
    fence_i,
    addi,
    slli,
    slti,
    sltiu,
    xori,
    srli,
    srai,
    ori,
    andi,
    auipc,
    addiw,
    slliw,
    srliw,
    sraiw,
    sb,
    sh,
    sw,
    sd,
    add,
    sll,
    slt,
    sltu,
    xor,
    srl,
    or_,
    and_,
    mul,
    mulh,
    mulhsu,
    mulhu,
    div,
    divu,
    rem,
    remu,
    sub,
    sra,
    lui,
    addw,
    sllw,
    srlw,
    mulw,
    divw,
    divuw,
    remw,
    remuw,
    subw,
    sraw,
    beq,
    bne,
    blt,
    bge,
    bltu,
    bgeu,
    jalr,
    jal,
    ecall,
    csrrc,
    csrrci,
    csrrs,
    csrrsi,
    csrrw,
    csrrwi,
    flw,
    fsw,
    fmadd_s,
    fmsub_s,
    fnmsub_s,
    fnmadd_s,
    fadd_s,
    fsub_s,
    fmul_s,
    fdiv_s,
    fsqrt_s,
    fsgnj_s,
    fsgnjn_s,
    fsgnjx_s,
    fmin_s,
    fmax_s,
    fcvt_w_s,
    fcvt_wu_s,
    fmv_x_w,
    feq_s,
    flt_s,
    fle_s,
    fclass_s,
    fcvt_s_w,
    fcvt_s_wu,
    fmv_w_x,
    fcvt_l_s,
    fcvt_lu_s,
    fcvt_s_l,
    fcvt_s_lu,
    fld,
    fsd,
    fmadd_d,
    fmsub_d,
    fnmsub_d,
    fnmadd_d,
    fadd_d,
    fsub_d,
    fmul_d,
    fdiv_d,
    fsqrt_d,
    fsgnj_d,
    fsgnjn_d,
    fsgnjx_d,
    fmin_d,
    fmax_d,
    fcvt_s_d,
    fcvt_d_s,
    feq_d,
    flt_d,
    fle_d,
    fclass_d,
    fcvt_w_d,
    fcvt_wu_d,
    fcvt_d_w,
    fcvt_d_wu,
    fcvt_l_d,
    fcvt_lu_d,
    fmv_x_d,
    fcvt_d_l,
    fcvt_d_lu,
    fmv_d_x,
};

pub const Instruction = struct {
    rd: GpReg,
    rs1: i8,
    rs2: i8,
    rs3: i8,
    imm: i32,
    csr: i16,

    ty: InsnType,
    rvc: bool,
    cont: bool,

    pub fn decode(data: u32) Instruction {
        const quad = QUADRANT(data);
        switch (quad) {
            inline else => unreachable,
        }
    }
};

inline fn readUtypeInsn(data: u32) Instruction {
    return .{
        .imm = data & 0xfffff000,
        .rd = RD(data),
    };
}

inline fn readItypeInsn(data: u32) Instruction {
    return .{
        .imm = @as(i32, @bitCast(data)) >> 20,
        .rs1 = RS1(data),
        .rd = RD(data),
    };
}

inline fn readJtypeInsn(data: u32) Instruction {
    const imm20 = (data >> 31) & 0x1;
    const imm101 = (data >> 21) & 0x3ff;
    const imm11 = (data >> 20) & 0x1;
    const imm1912 = (data >> 12) & 0xff;

    var imm: i32 = (imm20 << 20) | (imm1912 << 12) | (imm11 << 11) | (imm101 << 1);
    imm = (imm << 11) >> 11;

    return .{
        .imm = imm,
        .rd = RD(data),
    };
}

inline fn readBtypeInsn(data: u32) Instruction {
    const imm12 = (data >> 31) & 0x1;
    const imm105 = (data >> 25) & 0x3f;
    const imm41 = (data >> 8) & 0xf;
    const imm11 = (data >> 7) & 0x1;

    var imm: i32 = (imm12 << 12) | (imm11 << 11) | (imm105 << 5) | (imm41 << 1);
    imm = (imm << 19) >> 19;

    return .{
        .imm = imm,
        .rs1 = RS1(data),
        .rs2 = RS2(data),
    };
}

inline fn readRtypeInsn(data: u32) Instruction {
    return .{
        .rs1 = RS1(data),
        .rs2 = RS2(data),
        .rd = RD(data),
    };
}

inline fn readStypeInsn(data: u32) Instruction {
    const imm115 = (data >> 25) & 0x7f;
    const imm40 = (data >> 7) & 0x1f;

    var imm: i32 = (imm115 << 5) | imm40;
    imm = (imm << 20) >> 20;

    return .{
        .imm = imm,
        .rs1 = RS1(data),
        .rs2 = RS2(data),
    };
}

inline fn readCsrtypeInsn(data: u32) Instruction {
    return .{
        .csr = (data >> 20),
        .rs1 = RS1(data),
        .rd = RD(data),
    };
}

inline fn readFprtypeInsn(data: u32) Instruction {
    return .{
        .rs1 = RS1(data),
        .rs2 = RS2(data),
        .rs3 = RS3(data),
        .rd = RD(data),
    };
}

inline fn readCatypeInsn(data: u16) Instruction {
    return .{
        .rd = RP1(data) + 8,
        .rs2 = RP2(data) + 8,
        .rvc = true,
    };
}

inline fn readCrtypeInsn(data: u16) Instruction {
    return .{
        .rs1 = RC1(data),
        .rs2 = RC2(data),
        .rvc = true,
    };
}

inline fn readCitypeInsn(data: u16) Instruction {
    const imm40 = (data >> 2) & 0x1f;
    const imm5 = (data >> 12) & 0x1;
    var imm: i32 = (imm5 << 5) | imm40;
    imm = (imm << 26) >> 26;

    return .{
        .imm = imm,
        .rd = RC1(data),
        .rvc = true,
    };
}

inline fn readCitypeInsn2(data: u16) Instruction {
    const imm86 = (data >> 2) & 0x7;
    const imm43 = (data >> 5) & 0x3;
    const imm5 = (data >> 12) & 0x1;

    const imm: i32 = (imm86 << 6) | (imm43 << 3) | (imm5 << 5);

    return .{
        .imm = imm,
        .rd = RC1(data),
        .rvc = true,
    };
}

inline fn readCitypeInsn3(data: u16) Instruction {
    const imm5 = (data >> 2) & 0x1;
    const imm87 = (data >> 3) & 0x3;
    const imm6 = (data >> 5) & 0x1;
    const imm4 = (data >> 6) & 0x1;
    const imm9 = (data >> 12) & 0x1;

    var imm = (imm5 << 5) | (imm87 << 7) | (imm6 << 6) | (imm4 << 4) | (imm9 << 9);
    imm = (imm << 22) >> 22;

    return .{
        .imm = imm,
        .rd = RC1(data),
        .rvc = true,
    };
}

inline fn readCitypeInsn4(data: u16) Instruction {
    const imm5 = (data >> 12) & 0x1;
    const imm42 = (data >> 4) & 0x7;
    const imm76 = (data >> 2) & 0x3;

    const imm = (imm5 << 5) | (imm42 << 2) | (imm76 << 6);

    return .{
        .imm = imm,
        .rd = RC1(data),
        .rvc = true,
    };
}

inline fn readCitypeInsn5(data: u16) Instruction {
    const imm1612 = (data >> 2) & 0x1f;
    const imm17 = (data >> 12) & 0x1;

    var imm: i32 = (imm1612 << 12) | (imm17 << 17);
    imm = (imm << 14) >> 14;

    return .{
        .imm = imm,
        .rd = RC1(data),
        .rvc = true,
    };
}

inline fn readCbtypeInsn(data: u16) Instruction {
    const imm5 = (data >> 2) & 0x1;
    const imm21 = (data >> 3) & 0x3;
    const imm76 = (data >> 5) & 0x3;
    const imm43 = (data >> 10) & 0x3;
    const imm8 = (data >> 12) & 0x1;

    var imm: i32 = (imm8 << 8) | (imm76 << 6) | (imm5 << 5) | (imm43 << 3) | (imm21 << 1);
    imm = (imm << 23) >> 23;

    return .{
        .imm = imm,
        .rs1 = RP1(data) + 8,
        .rvc = true,
    };
}

inline fn readCbtypeInsn2(data: u16) Instruction {
    const imm40 = (data >> 2) & 0x1f;
    const imm5 = (data >> 12) & 0x1;
    var imm: i32 = (imm5 << 5) | imm40;
    imm = (imm << 26) >> 26;

    return .{
        .imm = imm,
        .rs1 = RP1(data) + 8,
        .rvc = true,
    };
}

inline fn readCstypeInsn(data: u16) Instruction {
    const imm76 = (data >> 5) & 0x3;
    const imm53 = (data >> 10) & 0x7;

    const imm: i32 = (imm76 << 6) | (imm53 << 3);

    return .{
        .imm = imm,
        .rs1 = RP1(data) + 8,
        .rs2 = RP2(data) + 8,
        .rvc = true,
    };
}

inline fn readCstypeInsn2(data: u16) Instruction {
    const imm6 = (data >> 5) & 0x1;
    const imm2 = (data >> 6) & 0x1;
    const imm53 = (data >> 10) & 0x7;

    const imm: i32 = (imm6 << 6) | (imm2 << 2) | (imm53 << 3);

    return .{
        .imm = imm,
        .rs1 = RP1(data) + 8,
        .rs2 = RP2(data) + 8,
        .rvc = true,
    };
}

inline fn readCjtypeInsn(data: u16) Instruction {
    const imm5 = (data >> 2) & 0x1;
    const imm31 = (data >> 3) & 0x7;
    // Yes, 6 and 7 transposed.
    const imm7 = (data >> 6) & 0x1;
    const imm6 = (data >> 7) & 0x1;
    const imm10 = (data >> 8) & 0x1;
    const imm98 = (data >> 9) & 0x3;
    const imm4 = (data >> 11) & 0x1;
    const imm11 = (data >> 12) & 0x1;

    var imm: i32 = (imm5 << 5) | (imm31 << 1) | (imm7 << 7) | (imm6 << 6) | (imm10 << 10) | (imm98 << 8) | (imm4 << 4) | (imm11 << 11);
    imm = (imm << 20) >> 20;

    return .{
        .imm = imm,
        .rvc = true,
    };
}

inline fn readCltypeInsn(data: u16) Instruction {
    const imm6 = (data >> 5) & 0x1;
    const imm2 = (data >> 6) & 0x1;
    const imm53 = (data >> 10) & 0x7;

    const imm: i32 = (imm6 << 6) | (imm2 << 2) | (imm53 << 3);

    return .{
        .imm = imm,
        .rs1 = RP1(data) + 8,
        .rd = RP2(data) + 8,
        .rvc = true,
    };
}

inline fn readCltypeInsn2(data: u16) Instruction {
    const imm76 = (data >> 5) & 0x3;
    const imm53 = (data >> 10) & 0x7;

    const imm: i32 = (imm76 << 6) | (imm53 << 3);

    return .{
        .imm = imm,
        .rs1 = RP1(data) + 8,
        .rd = RP2(data) + 8,
        .rvc = true,
    };
}

inline fn readCsstypeInsn(data: u16) Instruction {
    const imm86 = (data >> 7) & 0x7;
    const imm53 = (data >> 10) & 0x7;

    const imm: i32 = (imm86 << 6) | (imm53 << 3);

    return .{
        .imm = imm,
        .rs2 = RC2(data),
        .rvc = true,
    };
}

inline fn readCsstypeInsn2(data: u16) Instruction {
    const imm76 = (data >> 7) & 0x3;
    const imm52 = (data >> 9) & 0xf;

    const imm: i32 = (imm76 << 6) | (imm52 << 2);

    return .{
        .imm = imm,
        .rs2 = RC2(data),
        .rvc = true,
    };
}

inline fn readCiwtypeInsn(data: u16) Instruction {
    const imm3 = (data >> 5) & 0x1;
    const imm2 = (data >> 6) & 0x1;
    const imm96 = (data >> 7) & 0xf;
    const imm54 = (data >> 11) & 0x3;

    const imm: i32 = (imm3 << 3) | (imm2 << 2) | (imm96 << 6) | (imm54 << 4);

    return .{
        .imm = imm,
        .rd = RP2(data) + 8,
        .rvc = true,
    };
}

pub fn decode(data: u32) Instruction {
    const quadrant = QUADRANT(data);
    switch (quadrant) {
        InsnQuadrant.Q0 => {
            const copcode: u3 = @intCast(COPCODE(data));
            const rvc: u16 = @intCast(data);

            switch (copcode) {
                // C.ADDI4SPN
                0x0 => {
                    var insn = readCiwtypeInsn(rvc);
                    insn.rs1 = GpReg.sp;
                    insn.type = InsnType.addi;
                },
                // C.FLD
                0x1 => {
                    var insn = readCltypeInsn2(rvc);
                    insn.type = InsnType.fld;
                },
                // C.LW
                0x2 => {
                    var insn = readCltypeInsn(rvc);
                    insn.type = InsnType.lw;
                },
                // C.LD
                0x3 => {
                    var insn = readCltypeInsn2(rvc);
                    insn.type = InsnType.ld;
                },
                0x4 => {
                    @panic("Not implemented");
                },
                // C.FSD
                0x5 => {
                    var insn = readCstypeInsn(rvc);
                    insn.type = InsnType.fsd;
                },
                // C.SW
                0x6 => {
                    var insn = readCstypeInsn2(rvc);
                    insn.type = InsnType.sw;
                },
                // C.SD
                0x7 => {
                    var insn = readCstypeInsn(rvc);
                    insn.type = InsnType.sd;
                },
            }
        },
        InsnQuadrant.Q1 => {
            const copcode: u3 = @intCast(COPCODE(data));

            // TODO: why don't we set rvc=true?
            switch (copcode) {
                // C.ADDI
                0x0 => {
                    var insn = readCitypeInsn(data);
                    insn.rs1 = insn.rd;
                    insn.type = InsnType.addi;
                },
                // C.ADDIW
                0x1 => {
                    var insn = readCitypeInsn(data);
                    assert(insn.rd != GpReg.zero);

                    insn.rs1 = insn.rd;
                    insn.type = InsnType.addiw;
                },
                // C.LI
                0x2 => {
                    var insn = readCitypeInsn(data);
                    insn.rs1 = GpReg.zero;
                    // TODO: verify
                    insn.type = InsnType.addi;
                },
                0x3 => {
                    const rd = RC1(data);
                    // TODO: check if it's indeed the same as "rd == 2"
                    // C.ADDI16SP
                    if (rd == GpReg.sp) {
                        var insn = readCitypeInsn3(data);
                        assert(insn.imm != 0);
                        insn.rs1 = insn.rd;
                        insn.type = InsnType.addi;
                    }
                    // C.LUI
                    else {
                        var insn = readCitypeInsn5(data);
                        assert(insn.imm != 0);
                        insn.type = InsnType.lui;
                    }
                },
                0x4 => {
                    const cfunct2high = CFUNCT2HIGH(data);

                    switch (cfunct2high) {
                        // C.SRLI, C.SRAI, C.ANDI
                        0x0, 0x1, 0x2 => {
                            var insn = readCbtypeInsn2(data);
                            insn.rs1 = insn.rd;

                            if (cfunct2high == 0x0) {
                                insn.type = InsnType.srli;
                            } else if (cfunct2high == 0x1) {
                                insn.type = InsnType.srai;
                            } else {
                                insn.type = InsnType.andi;
                            }
                        },
                        0x3 => {
                            const cfunct1 = CFUNCT1(data);
                            switch (cfunct1) {
                                0x0 => {
                                    const cfunct2low = CFUNCT2LOW(data);
                                    var insn = readCatypeInsn(data);
                                    insn.rs1 = insn.rd;

                                    switch (cfunct2low) {
                                        // C.SUB
                                        0x0 => {
                                            insn.type = InsnType.sub;
                                        },
                                        // C.XOR
                                        0x1 => {
                                            insn.type = InsnType.xor;
                                        },
                                        // C.OR
                                        0x2 => {
                                            insn.type = InsnType.or_;
                                        },
                                        // C.AND
                                        0x3 => {
                                            insn.type = InsnType.and_;
                                        },
                                    }
                                },
                                0x1 => {
                                    const cfunct2low = CFUNCT2LOW(data);
                                    var insn = readCatypeInsn(data);
                                    insn.rs1 = insn.rd;

                                    switch (cfunct2low) {
                                        // C.SUBW
                                        0x0 => {
                                            insn.type = InsnType.subw;
                                        },
                                        // C.ADDW
                                        0x1 => {
                                            insn.type = InsnType.addw;
                                        },
                                    }
                                },
                            }
                        },
                    }
                },
                // C.J
                0x5 => {
                    var insn = readCjtypeInsn(data);
                    insn.rd = GpReg.zero;
                    insn.type = InsnType.jal;
                    insn.cont = true;
                },
                // C.BEQZ C.BNEZ
                0x6, 0x7 => {
                    var insn = readCbtypeInsn(data);
                    insn.rs2 = GpReg.zero;
                    insn.type = if (copcode == 0x6) InsnType.beq else InsnType.bne;
                },
            }
        },
        InsnQuadrant.Q2 => {
            const copcode = COPCODE(data);
            switch (copcode) {
                // C.SLLI
                0x0 => {
                    var insn = readCitypeInsn(data);
                    insn.rs1 = insn.rd;
                    insn.ty = InsnType.slli;
                },
                // C.FLDSP
                0x1 => {
                    var insn = readCitypeInsn2(data);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.fld;
                },
                // C.LWSP
                0x2 => {
                    var insn = readCitypeInsn4(data);
                    assert(insn.rd != 0);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.lw;
                },
                // C.LDSP
                0x3 => {
                    var insn = readCitypeInsn2(data);
                    assert(insn.rd != 0);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.ld;
                },
                // C.LDSP
                0x4 => {
                    var insn = readCitypeInsn2(data);
                    assert(insn.rd != 0);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.ld;
                },
                0x4 => {
                    const cfunct1 = CFUNCT1(data);
                    switch (cfunct1) {
                        0x0 => {
                            var insn = readCrtypeInsn(data);
                            if (insn.rs2 == 0) {
                                // C.JR
                                assert(insn.rs1 != 0);
                                insn.rd = GpReg.zero;
                                insn.ty = InsnType.jalr;
                                insn.cont = true;
                            } else {
                                // C.MV
                                insn.rd = insn.rs1;
                                insn.rs1 = GpReg.zero;
                                insn.ty = InsnType.add;
                            }
                        },
                        0x1 => {
                            var insn = readCrtypeInsn(data);
                            if (insn.rs1 == 0 and insn.rs2 == 0) {
                                fatal("unimplemented");
                            } else if (insn.rs2 == 0) {
                                // C.JALR
                                insn.rd = GpReg.ra;
                                insn.ty = InsnType.jalr;
                                insn.cont = true;
                            } else {
                                // C.ADD
                                insn.rd = insn.rs1;
                                insn.ty = InsnType.add;
                            }
                        },
                        else => {
                            fatal("unknown insn");
                        },
                    }
                },
                0x5 => {
                    // C.FSDSP
                    var insn = readCsstypeInsn(data);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.fsd;
                },
                0x6 => {
                    // C.SWSP
                    var insn = readCsstypeInsn2(data);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.sw;
                },
                0x7 => {
                    // C.SDSP
                    var insn = readCsstypeInsn(data);
                    insn.rs1 = GpReg.sp;
                    insn.ty = InsnType.sw;
                },
            }
        },
        InsnQuadrant.Q3 => {
            const opcode = OPCODE(data);
            switch (opcode) {
                0x0 => {
                    const funct3 = FUNCT3(data);
                    var insn = readItypeInsn(data);
                    switch (funct3) {
                        0x0 => {
                            insn.ty = InsnType.lb;
                        },
                        0x1 => {
                            insn.ty = InsnType.lh;
                        },
                        0x2 => {
                            insn.ty = InsnType.lw;
                        },
                        0x3 => {
                            insn.ty = InsnType.ld;
                        },
                        0x4 => {
                            insn.ty = InsnType.lbu;
                        },
                        0x5 => {
                            insn.ty = InsnType.lhu;
                        },
                        0x6 => {
                            insn.ty = InsnType.lwu;
                        },
                        else => {
                            fatal("unknown insn");
                        },
                    }
                },
                0x1 => {
                    const funct3 = FUNCT3(data);
                    var insn = readItypeInsn(data);
                    switch (funct3) {
                        0x2 => {
                            insn.ty = InsnType.flw;
                        },
                        0x3 => {
                            insn.ty = InsnType.fld;
                        },
                        else => {
                            fatal("unknown insn");
                        },
                    }
                    return insn;
                },
                // 0x2 => { },
                0x3 => {
                    const funct3 = FUNCT3(data);
                    switch (funct3) {
                        0x0 => {
                            return Instruction{
                                .ty = InsnType.fence,
                            };
                        },
                        0x1 => {
                            return Instruction{
                                .ty = InsnType.fence_i,
                            };
                        },
                        else => {
                            fatal("unknown insn");
                        },
                    }
                },
                0x4 => {
                    const funct3 = FUNCT3(data);
                    var insn = readItypeInsn(data);
                    switch (funct3) {
                        0x0 => {
                            // ADDI
                            insn.ty = InsnType.addi;
                        },
                        0x1 => {
                            const imm116 = IMM116(data);
                            if (imm116 == 0) {
                                insn.ty = InsnType.slli;
                            } else {
                                fatal("unknown insn");
                            }
                        },
                        0x2 => {
                            // SLTI
                            insn.ty = InsnType.slti;
                        },
                        0x3 => {
                            // SLTIU
                            insn.ty = InsnType.sltiu;
                        },
                        0x4 => {
                            // XORI
                            insn.ty = InsnType.xori;
                        },
                        0x5 => {
                            const imm116 = IMM116(data);
                            if (imm116 == 0x0) {
                                // SRLI
                                insn.ty = InsnType.srli;
                            } else if (imm116 == 0x10) {
                                // SRAI
                                insn.ty = InsnType.srai;
                            }
                        },
                        0x6 => {
                            // ORI
                            insn.ty = InsnType.ori;
                        },
                        0x7 => {
                            // ANDI
                            insn.ty = InsnType.andi;
                        },
                    }
                },
                0x5 => {
                    // AUIPC
                    var insn = readUtypeInsn(data);
                    insn.ty = InsnType.auipc;
                },
                0x6 => {
                    const funct3 = FUNCT3(data);
                    const funct7 = FUNCT7(data);
                    var insn = readItypeInsn(data);

                    switch (funct3) {
                        0x0 => {
                            // ADDIW
                            insn.ty = InsnType.addiw;
                        },
                        0x1 => {
                            // SLLIW
                            assert(funct7 == 0);
                            insn.ty = InsnType.slliw;
                        },
                        0x5 => {
                            switch (funct7) {
                                0x0 => {
                                    // SRLIW
                                    insn.ty = InsnType.srliw;
                                },
                                // TODO: 0x20? looks weird, check it
                                0x20 => {
                                    insn.ty = InsnType.srliw;
                                },
                            }
                        },
                        else => {
                            fatal("unimplemented");
                        },
                    }
                },
                // 0x7 => {}
                0x8 => {
                    const funct3 = FUNCT3(data);
                    var insn = readStypeInsn(data);
                    switch (funct3) {
                        0x0 => {
                            // SB
                            insn.ty = InsnType.sb;
                        },
                        0x1 => {
                            // SH
                            insn.ty = InsnType.sh;
                        },
                        0x2 => {
                            // SW
                            insn.ty = InsnType.sw;
                        },
                        0x3 => {
                            // SD
                            insn.ty = InsnType.sd;
                        },
                    }
                },
                0x9 => {
                    const funct3 = FUNCT3(data);
                    var insn = readStypeInsn(data);
                    switch (funct3) {
                        0x2 => {
                            // FSW
                            insn.ty = InsnType.fsw;
                        },
                        0x3 => {
                            // FSD
                            insn.ty = InsnType.fsd;
                        },
                    }
                },
                0xc => {
                    var insn = readRtypeInsn(data);
                    const funct3 = FUNCT3(data);
                    const funct7 = FUNCT7(data);

                    switch (funct7) {
                        0x0 => {
                            switch (funct3) {
                                0x0 => {
                                    // ADD
                                    insn.ty = InsnType.add;
                                },
                                0x1 => {
                                    // SLL
                                    insn.ty = InsnType.sll;
                                },
                                0x2 => {
                                    // SLT
                                    insn.ty = InsnType.slt;
                                },
                                0x3 => {
                                    // SLTU
                                    insn.ty = InsnType.sltu;
                                },
                                0x4 => {
                                    // XOR
                                    insn.ty = InsnType.xor;
                                },
                                0x5 => {
                                    // SRL
                                    insn.ty = InsnType.srl;
                                },
                                0x6 => {
                                    // OR
                                    insn.ty = InsnType.or_;
                                },
                                0x7 => {
                                    // AND
                                    insn.ty = InsnType.and_;
                                },
                            }
                        },
                        0x1 => {
                            switch (funct3) {
                                0x0 => {
                                    // MUL
                                    insn.ty = InsnType.mul;
                                },
                                0x1 => {
                                    // MULH
                                    insn.ty = InsnType.mulh;
                                },
                                0x2 => {
                                    // MULHSU
                                    insn.ty = InsnType.mulhsu;
                                },
                                0x3 => {
                                    // MULHU
                                    insn.ty = InsnType.mulhu;
                                },
                                0x4 => {
                                    // DIV
                                    insn.ty = InsnType.div;
                                },
                                0x5 => {
                                    // DIVU
                                    insn.ty = InsnType.divu;
                                },
                                0x6 => {
                                    // REM
                                    insn.ty = InsnType.rem;
                                },
                                0x7 => {
                                    // REMU
                                    insn.ty = InsnType.remu;
                                },
                            }
                        },
                        0x20 => {
                            switch (funct3) {
                                0x0 => {
                                    // SUB
                                    insn.ty = InsnType.sub;
                                },
                                0x5 => {
                                    // SRA
                                    insn.ty = InsnType.sra;
                                },
                                else => {
                                    fatal("unknown insn");
                                },
                            }
                        },
                    }
                },
                0xd => {
                    // LUI
                    var insn = readUtypeInsn(data);
                    insn.ty = InsnType.lui;
                },
                0xe => {
                    var insn = readRtypeInsn(data);
                    const funct3 = FUNCT3(data);
                    const funct7 = FUNCT7(data);
                    switch (funct7) {
                        0x0 => {
                            switch (funct3) {
                                0x0 => {
                                    // ADDW
                                    insn.ty = InsnType.addw;
                                },
                                0x1 => {
                                    // SLLW
                                    insn.ty = InsnType.sllw;
                                },
                                0x5 => {
                                    // SRLW
                                    insn.ty = InsnType.srlw;
                                },
                                else => {
                                    fatal("unknown insn");
                                },
                            }
                        },
                        0x1 => {
                            switch (funct3) {
                                0x0 => {
                                    // MULW
                                    insn.ty = InsnType.mulw;
                                },
                                0x4 => {
                                    // DIVW
                                    insn.ty = InsnType.divw;
                                },
                                0x5 => {
                                    // DIVUW
                                    insn.ty = InsnType.divuw;
                                },
                                0x6 => {
                                    // REMW
                                    insn.ty = InsnType.remw;
                                },
                                0x7 => {
                                    insn.ty = InsnType.remuw;
                                },
                                else => {
                                    fatal("unknown insn");
                                },
                            }
                        },
                        0x20 => {
                            switch (funct3) {
                                0x0 => {
                                    // SUBW
                                    insn.ty = InsnType.subw;
                                },
                                0x5 => {
                                    // SRAW
                                    insn.ty = InsnType.sraw;
                                },
                                else => {
                                    fatal("unknown insn");
                                },
                            }
                        },
                        else => {
                            fatal("unknown insn");
                        },
                    }
                },
                0x10 => {
                    const funct2 = FUNCT2(data);
                    var insn = readFprtypeInsn(data);
                    switch (funct2) {
                        0x0 => {
                            insn.ty = InsnType.fmadd_s;
                        },
                        0x1 => {
                            insn.ty = InsnType.fmadd_d;
                        },
                    }
                },
            }
        },
    }
}
