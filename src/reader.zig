const std = @import("std");
const tokenizer = @import("tokenizer.zig");

pub fn read_file(alloc: std.mem.Allocator, path: []const u8) anyerror![]u8 {
    const cwd = std.fs.cwd();
    var file = try cwd.openFile(path, .{ .mode = .read_only });
    defer file.close();

    return file.readToEndAlloc(alloc, 4096) catch |err| {
        return err;
    };
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
