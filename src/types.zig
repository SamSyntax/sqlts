const std = @import("std");
pub const Column = struct {
    name: []const u8,
    sql_type: []const u8,
    is_nullable: bool,
};

pub const Table = struct {
    name: []const u8,
    columns: []Column,
};
pub const KEYWORDS = [_][]const u8{
    "CREATE",
    "TABLE",
    "TEXT",
    "INT",
    "TIMESTAMP",
    "TIMESTAMPZ",
    "VARCHAR",
};

pub const DELIM = 59;

const AllocErr = std.mem.Allocator.Error;
const CustomErr = error{BadInput};

const TokenizerUnionError = union {
    AllocErr: AllocErr,
    CustomErr: CustomErr,
};

pub const TokenizerError = error{TokenizerUnionError};
