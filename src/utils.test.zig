const std = @import("std");
const utils = @import("utils.zig");

// ╔══════════════════════════════════════ toCamelCase TESTS ══════════════════════════════════════╗

const ToCamelTest = struct {
    input: []const u8,
    upperFirst: bool,
    expected: []const u8,
};

const toCamelTests = [_]ToCamelTest{
    .{
        .input = "post_users",
        .upperFirst = true,
        .expected = "PostUsers",
    },
    .{
        .input = "foo-bar baz",
        .upperFirst = true,
        .expected = "FooBarBaz",
    },
    .{
        .input = "hello_world",
        .upperFirst = false,
        .expected = "helloWorld",
    },
    .{
        .input = "",
        .upperFirst = true,
        .expected = "",
    },
};

test "toCamelCase variations" {
    const alloc = std.testing.allocator;
    std.debug.print("\n═══════════════ toCamelCase TESTS ═══════════════\n\n", .{});
    for (toCamelTests, 0..) |tc, i| {
        const got = try utils.toCamelCase(alloc, tc.input, tc.upperFirst);
        defer alloc.free(got);

        if (std.mem.eql(u8, tc.expected, got)) {
            std.debug.print("Test {d} passed! Expected: {s} | Got: {s}\n", .{ i + 1, tc.expected, got });
        } else {
            std.debug.print("Test {d} failed! Expected: {s} | Got: {s}\n", .{ i + 1, tc.expected, got });
        }
        try std.testing.expectEqualStrings(
            tc.expected,
            got,
        );
    }
}

// ╔══════════════════════════════════════ indexOfCI TESTS ══════════════════════════════════════╗

const IndexOfCITest = struct {
    haystack: []const u8,
    needle: []const u8,
    expected: ?usize,
};

const indexOfCiTests = [_]IndexOfCITest{
    .{
        .haystack = "user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4()",
        .needle = "primary key",
        .expected = 13,
    },
    .{
        .haystack = "test case form not null",
        .needle = "not null",
        .expected = 15,
    },
    .{
        .haystack = "created_at timestamp with time zone not null default now()",
        .needle = "primary key",
        .expected = null,
    },
    .{
        .haystack = "referrer_id  UUID            REFERENCES \"User\"(user_id) ON DELETE SET NULL,",
        .needle = "REFERENCES",
        .expected = 29,
    },
};

test "indexOfCI variations" {
    std.debug.print("\n══════════════e indexOfCI TESTS ═══════════════\n\n", .{});
    for (indexOfCiTests, 0..) |tc, i| {
        const got = utils.indexOfCI(tc.haystack, tc.needle);

        if (got == tc.expected) {
            std.debug.print("Test {d} passed! Expected: {?} | Got: {?}\n", .{ i + 1, tc.expected, got });
        } else {
            std.debug.print("Test {d} failed! Expected: {?} | Got: {?}\n", .{ i + 1, tc.expected, got });
        }

        try std.testing.expectEqual(tc.expected, got);
    }
}

// ╔══════════════════════════════════════ startsWithCI TESTS ══════════════════════════════════════╗

const StartsWithCITest = struct {
    haystack: []const u8,
    needle: []const u8,
    expected: bool,
};

const startsWithCITests = [_]StartsWithCITest{
    .{
        .haystack = "PRIMARY KEY DEFAULT uuid_generate_v4()",
        .needle = "primary key",
        .expected = true,
    },
    .{
        .haystack = "test case form not null",
        .needle = "not null",
        .expected = false,
    },
    .{
        .haystack = "created_at timestamp with time zone not null default now()",
        .needle = "primary key",
        .expected = false,
    },
    .{
        .haystack = "referrer_id  UUID            REFERENCES \"User\"(user_id) ON DELETE SET NULL",
        .needle = "REFERENCES",
        .expected = false,
    },
    .{
        .haystack = "REFERENCES \"User\"(user_id) ON DELETE SET NULL,",
        .needle = "REFERENCES",
        .expected = true,
    },
};

test "startsWithCI variations" {
    std.debug.print("\n═══════════════ startsWithCI TESTS ═══════════════\n\n", .{});
    for (startsWithCITests, 0..) |tc, i| {
        const got = utils.startsWithCI(tc.haystack, tc.needle);

        if (got == tc.expected) {
            std.debug.print("Test {d} passed! Expected: {any} | Got: {any}\n", .{ i + 1, tc.expected, got });
        } else {
            std.debug.print("Test {d} failed! Expected: {any} | Got: {any}\n", .{ i + 1, tc.expected, got });
        }

        try std.testing.expectEqual(tc.expected, got);
    }
}

// ╔══════════════════════════════════════ endsWithCI TESTS ══════════════════════════════════════╗

const EndsWithCITest = struct {
    haystack: []const u8,
    needle: []const u8,
    expected: bool,
};

const endsWithCITests = [_]EndsWithCITest{
    .{
        .haystack = "REFERENCES \"User\"(user_id) ON DELETE SET NULL",
        .needle = "NULL",
        .expected = true,
    },
    .{
        .haystack = "test case form not null",
        .needle = "not null",
        .expected = true,
    },
    .{
        .haystack = "PRIMARY KEY DEFAULT uuid_generate_v4()",
        .needle = "primary key",
        .expected = false,
    },
    .{
        .haystack = "created_at timestamp with time zone not null default now()",
        .needle = "primary key",
        .expected = false,
    },
    .{
        .haystack = "referrer_id  UUID            REFERENCES \"User\"(user_id) ON DELETE SET NULL,",
        .needle = "REFERENCES",
        .expected = false,
    },
};

test "endsWithCI variations" {
    std.debug.print("\n═══════════════ endsWithCI TESTS ═══════════════\n\n", .{});
    for (endsWithCITests, 0..) |tc, i| {
        const got = utils.endsWithCI(tc.haystack, tc.needle);

        if (got == tc.expected) {
            std.debug.print("Test {d} passed! Expected: {} | Got: {}\n", .{ i + 1, tc.expected, got });
        } else {
            std.debug.print("Test {d} failed! Expected: {} | Got: {}\n", .{ i + 1, tc.expected, got });
        }

        try std.testing.expectEqual(tc.expected, got);
    }
}

// ╔══════════════════════════════════════ mapSqlType TESTS ══════════════════════════════════════╗
const MapSqlTypeTest = struct {
    sqlType: []const u8,
    expected: []const u8,
};

const mapSqlTypeTests = [_]MapSqlTypeTest{
    .{
        .sqlType = "timestamp",
        .expected = "string",
    },
    .{
        .sqlType = "varchar",
        .expected = "string",
    },
    .{
        .sqlType = "varbinary",
        .expected = "string",
    },
    .{
        .sqlType = "tinytext",
        .expected = "string",
    },
    .{
        .sqlType = "text",
        .expected = "string",
    },
    .{
        .sqlType = "mediumtext",
        .expected = "string",
    },
    .{
        .sqlType = "longtext",
        .expected = "string",
    },
    .{
        .sqlType = "int",
        .expected = "number",
    },
    .{
        .sqlType = "integer",
        .expected = "number",
    },
    .{
        .sqlType = "bit",
        .expected = "number",
    },
    .{
        .sqlType = "tinyint",
        .expected = "number",
    },
    .{
        .sqlType = "mediumint",
        .expected = "number",
    },
    .{
        .sqlType = "float",
        .expected = "number",
    },
    .{
        .sqlType = "double",
        .expected = "number",
    },
    .{
        .sqlType = "serial",
        .expected = "number",
    },
    .{
        .sqlType = "decimal",
        .expected = "number",
    },
    .{
        .sqlType = "dec",
        .expected = "number",
    },
    .{
        .sqlType = "tinyblob",
        .expected = "any",
    },
    .{
        .sqlType = "mediumblob",
        .expected = "any",
    },
    .{
        .sqlType = "blob",
        .expected = "any",
    },
    .{
        .sqlType = "longblob",
        .expected = "any",
    },
    .{
        .sqlType = "binary",
        .expected = "any",
    },
    .{
        .sqlType = "",
        .expected = "any",
    },
};

test "mapSqlType variations" {
    std.debug.print("\n═══════════════ mapSqlType TESTS ═══════════════\n\n", .{});
    const alloc = std.testing.allocator;
    for (mapSqlTypeTests, 0..) |tc, i| {
        const got = try utils.mapSqlType(alloc, tc.sqlType);

        if (std.mem.eql(u8, got, tc.expected)) {
            std.debug.print("Test {d} ({s}) passed! Expected: {s} | Got: {s}\n", .{ i + 1, tc.sqlType, tc.expected, got });
        } else {
            std.debug.print("Test {d} ({s}) failed! Expected: {s} | Got: {s}\n", .{ i + 1, tc.sqlType, tc.expected, got });
        }

        try std.testing.expectEqual(tc.expected, got);
    }
}

// ╔══════════════════════════════════════ isColumnDef TESTS ══════════════════════════════════════╗

const IsColumnDefTest = struct { input: []const u8, expected: bool };

const IsColumnDefTests = [_]IsColumnDefTest{
    .{
        .input = "order_id    BIGSERIAL",
        .expected = true,
    },
    .{
        .input = "user_ref    UUID          NOT NULL REFERENCES \"User\"(user_id),",
        .expected = true,
    },
    .{
        .input = "price_cents   INTEGER      NOT NULL CHECK (price_cents >= 0),",
        .expected = true,
    },
    .{
        .input = "CHECK (char_length(name) <= 50)",
        .expected = false,
    },
    .{
        .input = "PRIMARY KEY (\"order-id\",\"user-ref\",item_id),",
        .expected = false,
    },
    .{
        .input = "REFERENCES order_header(order_id,user_ref)",
        .expected = true,
    },
};

test "isColumnDef variations" {
    std.debug.print("\n═══════════════ mapSqlType TESTS ═══════════════\n\n", .{});

    for (IsColumnDefTests, 0..) |tc, i| {
        const got = utils.isColumnDef(tc.input);

        if (tc.expected == got) {
            std.debug.print("Test {d} passed! Expected: {any} | Got: {any}\n", .{ i + 1, tc.expected, got });
        } else {
            std.debug.print("Test {d} failed! Expected: {any} | Got: {any}\n", .{ i + 1, tc.expected, got });
        }
        try std.testing.expectEqual(tc.expected, got);
    }
}
