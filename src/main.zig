const std = @import("std");
const tokenizer = @import("tokenizer.zig");
const reader = @import("reader.zig");
const utils = @import("utils.zig");

// pub fn main() !void {
//     const alloc = std.heap.page_allocator;
//
//     var args = std.process.args();
//     var i: usize = 0;
//     while (args.next()) |arg| {
//         if (i == 0) {
//             i += 1;
//             continue;
//         }
//         std.debug.print("arg{d}: {s}\n", .{ i, arg });
//         i += 1;
//     }
//     const cwd = std.fs.cwd();
//     var buf: [std.fs.max_path_bytes]u8 = undefined;
//     const rel_path = "./sql-examples";
//     const abs_path = try cwd.realpath(rel_path, &buf);
//
//     reader.read_dir(alloc, abs_path) catch |err| {
//         std.debug.print("> [error] failed to read files, err={}\n", .{err});
//         return;
//     };
// }

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    // parse CLI args
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    if (args.len != 3) {
        std.debug.print("usage: {s} <schema.sql> <out.ts>\n", .{args[0]});
        return;
    }
    const schema_path = args[1];
    const out_path = args[2];

    // load + strip comments
    const schema_bytes = try reader.read_file(alloc, schema_path);
    const clean_sql = try utils.removeComments(alloc, schema_bytes);

    // parse tables
    const tables = try tokenizer.parseSchema(alloc, clean_sql);

    // emit TypeScript
    try tokenizer.emitTsFile(tables, out_path);
}
