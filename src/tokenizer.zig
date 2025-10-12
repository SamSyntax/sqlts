const std = @import("std");
const types = @import("types.zig");

pub fn tokenizer(content: []const u8, alloc: std.mem.Allocator) anyerror![][]const u8 {
    var list = std.ArrayList([]const u8).initCapacity(alloc, 32) catch |err| {
        std.debug.print("> [error] couldn't init list with for tokenizer, err{}\n", .{err});
        return err;
    };
    defer list.deinit(alloc);
    var idx_cp: usize = 0;
    for (content, 0..) |value, i| {
        if (value == types.DELIM) {
            try list.append(alloc, content[idx_cp .. i + 1]);
            idx_cp = i + 1;
            std.debug.print("[DEBUG] Query has been tokenized\n", .{});
            continue;
        }
    }

    const clone = list.clone(alloc) catch |err| {
        return err;
    };

    return clone.items;
}
