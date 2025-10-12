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
    for (toCamelTests) |tc| {
        const got = try utils.toCamelCase(alloc, tc.input, tc.upperFirst);
        defer alloc.free(got);

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
    for (indexOfCiTests) |tc| {
        const got = utils.indexOfCI(tc.haystack, tc.needle);

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
        .haystack = "referrer_id  UUID            REFERENCES \"User\"(user_id) ON DELETE SET NULL,",
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
    for (startsWithCITests) |tc| {
        const got = utils.startsWithCI(tc.haystack, tc.needle);

        try std.testing.expectEqual(tc.expected, got);
    }
}
