pub fn quadrant(comptime T: type, instrWord: T) InstrQuadrant {
    return @enumFromInt(instrWord & 0x3);
}

const InstrQuadrant = enum(u2) {
    Q0,
    Q1,
    Q2,
    Q3,
};

const InstrType = enum(u32) {
    addi,
};

pub const Instruction = struct {
    rd: i8,
    rs1: i8,
    rs2: i8,
    imm: i32,

    ty: InstrType,
    rvc: bool,
    cont: bool,

    pub fn decode(comptime T: type, instrWord: T) Instruction {
        const quad = quadrant(T, instrWord);
        switch (quad) {
            inline else => unreachable,
        }
    }
};
