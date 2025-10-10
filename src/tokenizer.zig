const std = @import("std");

const KEYWORDS = enum {
    CREATE,
    TABLE,
    TEXT,
    INT,
    TIMESTAMP,
    TIMESTAMPZ,
    VARCHAR,
};

const NULL_TERM = '0x20';

pub fn tokenizer(content: []const u8) !void {
    for (content, 0..) |value, i| {
        std.debug.print("Char[{d}]: {c}, rune: {x}\n", .{ i, value, value });
    }
}
