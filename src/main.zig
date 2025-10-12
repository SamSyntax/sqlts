const std = @import("std");
const parser = @import("parser.zig");
const reader = @import("reader.zig");
const utils = @import("utils.zig");
const types = @import("types.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    if (args.len != 3) {
        std.debug.print("usage: {s} <schema.sql> <out.ts>\n", .{args[0]});
        return;
    }
    const schema_path = args[1];
    const out_path = args[2];

    const schema_files = reader.read_dir(alloc, schema_path) catch |err| {
        std.debug.print("{}\n", .{err});
        return;
    };

    var all_tables = std.ArrayList(types.Table).initCapacity(alloc, 4) catch |err| {
        std.debug.print(">[error] coudln't initialize array list for all tables, err={}\n", .{err});
        return;
    };

    for (schema_files.items) |path| {
        const schema_bytes = try reader.read_file(alloc, path);
        const clean_sql = try utils.removeComments(alloc, schema_bytes);

        const tables = try parser.parseSchema(alloc, clean_sql);
        for (tables.items) |table| {
            try all_tables.append(alloc, table);
        }
    }
    try parser.emitTsFile(all_tables, out_path);
}
