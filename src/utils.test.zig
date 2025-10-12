const std = @import("std");
const testing = std.testing;
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
