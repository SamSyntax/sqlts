const std = @import("std");
const parser = @import("parser.zig");
const types = @import("types.zig");

// ╔══════════════════════════════════════ parseSchema TESTS ══════════════════════════════════════╗
const ParseSchemaTest = struct {
    name: []const u8,
    sql: []const u8,
    expectedTables: []const []const u8,
    expectedCols: []const usize,
};

const ParseSchemaTests = [_]ParseSchemaTest{
    .{
        .name = "single simple table",
        .sql = "CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(50));",
        .expectedTables = &[_][]const u8{"users"},
        .expectedCols = &[_]usize{2},
    },
    .{
        .name = "two tables",
        .sql =
        \\ CREATE TABLE a (x INT);
        \\ CREATE TABLE b (y TEXT, z BOOL);
        ,
        .expectedTables = &[_][]const u8{ "a", "b" },
        .expectedCols = &[_]usize{ 1, 2 },
    },
};

test "parseSchema variations" {
    std.debug.print("\n═══════════════ parseSchema TESTS ═══════════════\n\n", .{});

    const alloc = std.testing.allocator;

    for (ParseSchemaTests, 0..) |tc, i| {
        var got = try parser.parseSchema(alloc, tc.sql);
        defer {
            for (got.items) |*t| {
                for (t.columns.items) |c| {
                    alloc.free(c.ts_name);
                }
                t.columns.deinit(alloc);
                alloc.free(t.ts_name);
            }
            got.deinit(alloc);
        }
        std.debug.print("Test {d}: {s}\n", .{ i + 1, tc.name });
        try std.testing.expect(got.items.len == tc.expectedTables.len);
        for (got.items, 0..) |table, ti| {
            try std.testing.expectEqualStrings(tc.expectedTables[ti], table.name);
            try std.testing.expect(table.columns.items.len == tc.expectedCols[ti]);
        }
    }
}
