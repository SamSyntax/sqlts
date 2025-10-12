const std = @import("std");
const tokenizer = @import("tokenizer.zig");
const reader = @import("reader.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    var args = std.process.args();
    var i: usize = 0;
    while (args.next()) |arg| {
        if (i == 0) {
            i += 1;
            continue;
        }
        std.debug.print("arg{d}: {s}\n", .{ i, arg });
        i += 1;
    }
    const cwd = std.fs.cwd();
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const rel_path = "./sql-examples";
    const abs_path = try cwd.realpath(rel_path, &buf);

    reader.read_dir(alloc, abs_path) catch |err| {
        std.debug.print("> [error] failed to read files, err={}\n", .{err});
        return;
    };
}
