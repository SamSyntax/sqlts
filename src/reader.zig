const std = @import("std");
const parser = @import("parser.zig");

pub fn read_file(alloc: std.mem.Allocator, path: []const u8) anyerror![]u8 {
    const cwd = std.fs.cwd();
    var file = try cwd.openFile(path, .{ .mode = .read_only });
    defer file.close();

    return file.readToEndAlloc(alloc, 4096) catch |err| {
        return err;
    };
}

fn get_absolute(path: []const u8) []const u8 {
    const cwd = std.fs.cwd();
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const absolutePath = cwd.realpath(path, &buf) catch |err| {
        std.debug.print("> [error] abs_path couldn't be established, err={}\n", .{err});
        return "";
    };
    return absolutePath;
}

pub fn read_dir(alloc: std.mem.Allocator, path: []const u8) anyerror!std.ArrayList([]u8) {
    const abs_path = get_absolute(path);
    var dir = std.fs.openDirAbsolute(abs_path, .{ .iterate = true }) catch |err| {
        std.debug.print("> [error] opening absolute dir by provided path, err{}\n", .{err});
        return err;
    };
    defer dir.close();
    var paths = std.ArrayList([]u8).initCapacity(alloc, 4) catch |err| {
        return err;
    };
    var walker = try dir.walk(alloc);
    defer walker.deinit();
    while (try walker.next()) |entry| {
        const full_path = std.fs.path.join(alloc, &[2][]const u8{
            path,
            entry.path,
        }) catch |err| {
            std.debug.print("> [error] failed to join paths and construct an absolute path from {s} and {s}, err={}\n", .{ path, entry.path, err });
            return err;
        };
        try paths.append(alloc, full_path);
    }

    return paths;
}
