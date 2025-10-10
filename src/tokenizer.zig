const std = @import("std");

const KEYWORDS = [_][]const u8{
    "CREATE",
    "TABLE",
    "TEXT",
    "INT",
    "TIMESTAMP",
    "TIMESTAMPZ",
    "VARCHAR",
};

const DELIM = 59;
pub fn tokenizer(content: []const u8, alloc: std.mem.Allocator) !void {
    var list = std.ArrayList([]const u8).initCapacity(alloc, 32) catch |err| {
        std.debug.print("> [error] couldn't init list with for tokenizer, err{}\n", .{err});
        return;
    };
    defer list.deinit(alloc);
    var idx_cp: usize = 0;
    for (content, 0..) |value, i| {
        if (value == 10 or value == 32 or value == 41) {
            const token = content[idx_cp..i];
            if (token.len == 0) {
                continue;
            } else {
                const trimmed = std.mem.trim(u8, std.mem.trim(u8, token, std.ascii.whitespace[0..]), ",");
                if (trimmed.len == 0) {
                    continue;
                } else {
                    var buf: [256]u8 = undefined;
                    const norm = std.ascii.upperString(&buf, trimmed);
                    for (KEYWORDS) |val| {
                        if (std.mem.eql(u8, val, norm)) {
                            std.debug.print("\n[DEBUG] Crikey\r\n", .{});
                            continue;
                        }
                    }
                    std.debug.print("token={s}\n", .{trimmed});
                    list.append(alloc, trimmed) catch unreachable;
                }
            }
            idx_cp = i + 1;
        }
        if (value == DELIM) {
            std.debug.print("[DEBUG] Query has been tokenized\n", .{});
            continue;
        }
    }
}
