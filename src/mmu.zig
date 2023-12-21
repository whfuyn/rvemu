const std = @import("std");
const os = std.os;
const math = std.math;
const mem = std.mem;
const elf = @import("elf.zig");

const GUEST_MEMORY_OFFSET = 0x088800000000;

pub fn toHost(addr: usize) usize {
    return addr + GUEST_MEMORY_OFFSET;
}

pub fn toGuest(addr: usize) usize {
    return addr - GUEST_MEMORY_OFFSET;
}

// Round down by page size
pub fn roundDown(v: usize, k: usize) usize {
    std.debug.assert(mem.isValidAlign(k));
    return v & ~(k - 1);
}

// Round up by page size
pub fn roundUp(v: usize, k: usize) usize {
    std.debug.assert(mem.isValidAlign(k));
    // TODO: Check if -%k is indeed the same as ~k+1
    return (v + (k - 1)) & (-%k);
}

pub fn flagsToProt(flags: u32) u32 {
    var prot: u32 = 0;
    if (flags & elf.PF_R != 0) {
        prot |= os.PROT.READ;
    }
    if (flags & elf.PF_W != 0) {
        prot |= os.PROT.WRITE;
    }
    if (flags & elf.PF_X != 0) {
        prot |= os.PROT.EXEC;
    }
    return prot;
}

pub const Error = error{
    FailToMmapTargetAddr,
    InvalidPhdrAlignment,
};

pub const Mmu = struct {
    entry: u64 = 0,
    host_alloc: u64 = 0,
    alloc: u64 = 0,
    base: u64 = 0,

    pub fn loadElf(self: *Mmu, elf_bytes: []align(@alignOf(elf.Elf64Ehdr)) u8) !void {
        const ehdr = try elf.Elf64Ehdr.fromBytes(elf_bytes);
        self.entry = ehdr.e_entry;
        // std.debug.print("phnum {d}", .{ehdr.e_phnum});

        if (!std.mem.isAligned(@intFromPtr(elf_bytes[ehdr.e_phoff..].ptr), @alignOf(elf.Elf64Phdr)) or // !std.mem.isAligned(ehdr.e_phentsize, @alignOf(elf.Elf64Phdr)))
            !std.mem.isAligned(@sizeOf(elf.Elf64Phdr), @alignOf(elf.Elf64Phdr)))
        {
            return Error.InvalidPhdrAlignment;
        }

        for (0..ehdr.e_phnum) |i| {
            // Will it open an attack window if the e_phentsize is not indeed the size of elf.Elf64Phdr?
            // const offset = ehdr.e_phoff + i * ehdr.e_phentsize;
            const offset = ehdr.e_phoff + i * @sizeOf(elf.Elf64Phdr);

            const phdr_bytes: []align(@alignOf(elf.Elf64Phdr)) const u8 = @alignCast(elf_bytes[offset .. offset + @sizeOf(elf.Elf64Phdr)]);
            const phdr = try elf.Elf64Phdr.fromBytes(phdr_bytes);
            std.debug.print("{any}\n", .{phdr});
            if (phdr.p_type == elf.PT_LOAD) {
                try self.loadSegment(phdr, elf_bytes);
            }
        }
    }

    pub fn loadSegment(self: *Mmu, phdr: *const elf.Elf64Phdr, elf_bytes: []u8) !void {
        // TODO:
        // mem.page_size will be removed. https://github.com/ziglang/zig/issues/4082
        const page_size = mem.page_size;

        const offset = phdr.p_offset;
        const vaddr = toHost(phdr.p_vaddr);
        const aligned_vaddr = roundDown(vaddr, page_size);
        const filesz = phdr.p_filesz + (vaddr - aligned_vaddr);
        const memsz = phdr.p_memsz + (vaddr - aligned_vaddr);

        // TODO: use native API for memory mapping on Windows.
        const prot = flagsToProt(phdr.p_flags);
        // We need the WRITE permission to load segment data.
        // Notice that implict alignment requirement imposed after @ptrFromInt.
        std.debug.assert(mem.isAligned(aligned_vaddr, page_size));
        // Round up filesz to page size
        const addr = try os.mmap(@ptrFromInt(aligned_vaddr), roundUp(filesz, page_size), os.PROT.WRITE, os.MAP.ANONYMOUS | os.MAP.PRIVATE | os.MAP.FIXED, -1, 0);
        if (@intFromPtr(addr.ptr) != aligned_vaddr) {
            return Error.FailToMmapTargetAddr;
        }
        @memcpy(
            addr[0..filesz],
            elf_bytes[offset .. offset + filesz],
        );
        // After copying segment data, restore the protection.
        try os.mprotect(addr, prot);

        const remaining_bss_size = roundUp(memsz, page_size) - roundUp(filesz, page_size);
        if (remaining_bss_size > 0) {
            const expect_remaining_bss = aligned_vaddr + roundUp(filesz, page_size);
            const remaining_bss = try os.mmap(@ptrFromInt(expect_remaining_bss), remaining_bss_size, prot, os.MAP.ANONYMOUS | os.MAP.PRIVATE | os.MAP.FIXED, -1, 0);
            if (@intFromPtr(remaining_bss.ptr) != expect_remaining_bss) {
                return Error.FailToMmapTargetAddr;
            }
        }

        // TODO: make sure we understand what it is doing.
        self.host_alloc = @max(self.host_alloc, (aligned_vaddr + roundUp(memsz, page_size)));
        self.alloc = toGuest(self.host_alloc);
        self.base = toGuest(self.host_alloc);
    }
};
