const std = @import("std");
const ELFMAG = [4]u8{ 0x7f, 0x45, 0x4c, 0x46 };

const EM_RISCV = 0xf3;
const EM_X86_64 = 0x3e;

const ELFCLASS64 = 2;

const EI_NIDENT = 16;
const EI_CLASS = 4;

pub const PF_X = 0x1;
pub const PF_W = 0x2;
pub const PF_R = 0x4;

pub const PT_LOAD = 0x1;

const Error = error{
    InvalidElf,
    BytesTooShort,
    BadElf,
    UnsupportedArch,
};

pub const Elf64Ehdr = extern struct {
    e_ident: [EI_NIDENT]u8,
    e_type: u16,
    e_machine: u16,
    e_version: u32,
    e_entry: u64,
    e_phoff: u64,
    e_shoff: u64,
    e_flags: u32,
    e_ehsize: u16,
    e_phentsize: u16,
    e_phnum: u16,
    e_shentsize: u16,
    e_shnum: u16,
    e_shstrndx: u16,

    pub fn fromBytes(bytes: []align(@alignOf(Elf64Ehdr)) const u8) !*const Elf64Ehdr {
        if (bytes.len < @sizeOf(Elf64Ehdr)) {
            return Error.BytesTooShort;
        }
        const ehdr: *const Elf64Ehdr = std.mem.bytesAsValue(Elf64Ehdr, bytes[0..@sizeOf(Elf64Ehdr)]);

        if (!std.mem.eql(u8, ehdr.e_ident[0..4], &ELFMAG)) {
            return Error.InvalidElf;
        }
        if (ehdr.e_machine != EM_RISCV and ehdr.e_machine != EM_X86_64) {
            return Error.UnsupportedArch;
        }
        if (ehdr.e_ident[EI_CLASS] != ELFCLASS64) {
            return Error.UnsupportedArch;
        }
        return ehdr;
    }
};

pub const Elf64Phdr = extern struct {
    p_type: u32,
    p_flags: u32,
    p_offset: u64,
    p_vaddr: u64,
    p_paddr: u64,
    p_filesz: u64,
    p_memsz: u64,
    p_align: u64,

    pub fn fromBytes(bytes: []align(@alignOf(Elf64Phdr)) const u8) !*const Elf64Phdr {
        if (bytes.len < @sizeOf(Elf64Phdr)) {
            return Error.BytesTooShort;
        }
        const phdr: *const Elf64Phdr = std.mem.bytesAsValue(Elf64Phdr, bytes[0..@sizeOf(Elf64Phdr)]);
        return phdr;
    }

    pub fn fromElfBytes(ehdr: *const Elf64Ehdr, idx: usize, elf_bytes: []align(@alignOf(Elf64Phdr)) const u8) !*const Elf64Phdr {
        const offset = ehdr.e_phoff + idx * ehdr.e_phentsize;
        // TODO: Should I insert this check here to make sure that the bytes are aligned even in ReleaseFast?
        std.debug.assert(std.mem.isAligned(elf_bytes[offset..], @alignOf(Elf64Phdr)));
        // const phdr_bytes: *align(@alignOf(Elf64Phdr)) const [@sizeOf(Elf64Phdr)]u8 = @alignCast(elf_bytes[offset .. offset + @sizeOf(Elf64Phdr)]);
        const phdr_bytes: [@sizeOf(Elf64Phdr)]u8 align(@alignOf(Elf64Phdr)) = @alignCast(elf_bytes[offset .. offset + @sizeOf(Elf64Phdr)]);
        const phdr: *const Elf64Phdr = std.mem.bytesAsValue(Elf64Phdr, phdr_bytes);
        return phdr;
    }
};
