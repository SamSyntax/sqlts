const std = @import("std");
const tokenizer = @import("tokenizer.zig");

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

    read_dir(alloc, abs_path) catch |err| {
        std.debug.print("> [error] failed to read files, err={}\n", .{err});
        return;
    };
}

fn read_file(alloc: std.mem.Allocator, path: []const u8) !void {
    var file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch |err| {
        std.debug.print("> [error] failed to open file: {s}, err={}\n", .{ path, err });
        return;
    };
    defer file.close();
    const endpos = file.getEndPos() catch |err| {
        std.debug.print("> [error] failed to get endpos of the file {s}, err={}\n", .{ path, err });
        return;
    };
    // std.debug.print("[DEBUG]: {d}\n", .{endpos});
    const content = try file.readToEndAlloc(alloc, endpos);
    // std.debug.print("[DEBUG] content len: {d}\nContent: {s}\n", .{ content.len, content });
    tokenizer.tokenizer(content, alloc) catch unreachable;
}

fn read_dir(alloc: std.mem.Allocator, path: []const u8) !void {
    var dir = std.fs.openDirAbsolute(path, .{ .iterate = true }) catch |err| {
        std.debug.print("> [error] opening absolute dir by provided path, err{}\n", .{err});
        return;
    };
    defer dir.close();
    var walker = try dir.walk(alloc);
    defer walker.deinit();
    while (try walker.next()) |entry| {
        const full_path = std.fs.path.join(alloc, &[2][]const u8{
            path,
            entry.path,
        }) catch |err| {
            std.debug.print("> [error] failed to join paths and construct an absolute path from {s} and {s}, err={}\n", .{ path, entry.path, err });
            return;
        };
        std.debug.print("[DEBUG] {s}\n", .{full_path});
        read_file(alloc, full_path) catch |err| {
            std.debug.print("> [error] failed to read contents of {s}/{s} file, err={}\n", .{ path, entry.path, err });
            return;
        };
    }
}
