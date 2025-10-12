const std = @import("std");
pub const Column = struct {
    name: []const u8,
    ts_name: []const u8,
    sql_type: []const u8,
    ts_type: []const u8,
    is_nullable: bool,
};

pub const Table = struct {
    name: []const u8,
    ts_name: []const u8,
    columns: std.ArrayList(Column),
};
pub const DELIM = 59;
