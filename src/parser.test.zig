const std = @import("std");
const parser = @import("parser.zig");
const types = @import("types.zig");

// ╔══════════════════════════════════════ parseSchema TESTS ══════════════════════════════════════╗
const ParseSchemaTest = struct {
    name: []const u8,
    sql: []const u8,
    expectedTables: []const []const u8,
    expectedCols: []usize,
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
    const alloc = std.testing.allocator;

    for (ParseSchemaTests, 0..) |tc, i| {
        const schema = try parser.parseSchema(alloc, tc.sql);
        std.debug.print("Test {d}: {s}\n", .{ i + 1, tc.name });
        try std.testing.expect(schema.items.len == tc.expectedTables.len);
        for (schema.items, 0..) |table, ti| {
            try std.testing.expectEqualStrings(tc.expectedTables[ti], table.name);
            try std.testing.expect(table.columns.len == tc.expectedCols[ti]);
        }
    }
}

// test "parseSchema: simple table" {
//     const allocator = std.testing.allocator;
//     const src =
//         \\ CREATE TABLE users (
//         \\   id   INT PRIMARY KEY,
//         \\  name VARCHAR(255) NOT NULL,
//         \\  bio  TEXT
//         \\);
//     ;
//
//     const schema = try parser.parseSchema(allocator, src);
//
//     std.testing.expect(schema.tables.len == 1);
//     const users = schema.tables[0];
//     std.testing.expectEqualStrings("users", users.name);
//     std.testing.expect(users.columns.len == 3);
//
//     const col0 = users.columns[0];
//     std.testing.expectEqualStrings("id", col0.name);
//     std.testing.expect(col0.typ == parser.SqlType.Int);
//     std.testing.expect(col0.isPrimaryKey);
//
//     const col1 = users.columns[1];
//     std.testing.expectEqualStrings("name", col1.name);
//     std.testing.expect(col1.typ == parser.SqlType.Varchar);
//     std.testing.expect(!col1.isNullable);
//     std.testing.expect(col1.length == 255);
//
//     // Third column (TEXT defaults to nullable = true)
//     const col2 = users.columns[2];
//     std.testing.expectEqualStrings("bio", col2.name);
//     std.testing.expect(col2.typ == parser.SqlType.Text);
//     std.testing.expect(col2.isNullable);
// }
//
// test "parseSchema: multiple tables" {
//     const allocator = std.testing.allocator;
//     const src =
//         \\ CREATE TABLE a (x INT);
//         \\ CREATE TABLE b (y TEXT);
//     ;
//     const schema = try parser.parseSchema(allocator, src);
//     std.testing.expect(schema.tables.len == 2);
//     std.testing.expectEqualStrings("a", schema.tables[0].name);
//     std.testing.expectEqualStrings("b", schema.tables[1].name);
// }
