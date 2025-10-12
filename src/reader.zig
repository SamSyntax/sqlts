const std = @import("std");
const tokenizer = @import("tokenizer.zig");

pub fn read_file(alloc: std.mem.Allocator, path: []const u8) anyerror!void {
    var file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch |err| {
        std.debug.print("> [error] failed to open file: {s}, err={}\n", .{ path, err });
        return err;
    };
    defer file.close();
    const endpos = file.getEndPos() catch |err| {
        std.debug.print("> [error] failed to get endpos of the file {s}, err={}\n", .{ path, err });
        return err;
    };
    // std.debug.print("[DEBUG]: {d}\n", .{endpos});
    const content = try file.readToEndAlloc(alloc, endpos);
    // std.debug.print("[DEBUG] content len: {d}\nContent: {s}\n", .{ content.len, content });
    const queries = tokenizer.tokenizer(content, alloc) catch |err| {
        return err;
    };

    for (queries) |query| {
        std.debug.print("{s}\n", .{query});
    }
}

pub fn read_dir(alloc: std.mem.Allocator, path: []const u8) !void {
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
