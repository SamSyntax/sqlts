const std = @import("std");

pub fn toCamelCase(alloc: std.mem.Allocator, s: []const u8, upperFirst: bool) ![]u8 {
    var list = try std.ArrayList(u8).initCapacity(alloc, 8);
    var nextUpper = upperFirst;
    for (s) |c| {
        if (c == '_' or c == '-' or c == ' ') {
            nextUpper = true;
        } else {
            var out = c;
            if (nextUpper) {
                out = toUpper(c);
                nextUpper = false;
            } else {
                out = toLower(c);
            }
            try list.append(alloc, out);
        }
    }
    return list.toOwnedSlice(alloc);
}

pub fn indexOfCI(h: []const u8, n: []const u8) ?usize {
    const hlen = h.len;
    const nlen = n.len;
    if (nlen == 0) return 0;
    if (hlen < n.len) return null;
    const last = hlen - nlen;
    for (0..last + 1) |i| {
        var ok = true;
        for (n, 0..) |c, j| {
            if (toLower(h[i + j]) != toLower(c)) {
                ok = false;
                break;
            }
        }
        if (ok) return i;
    }
    return null;
}

pub fn startsWithCI(h: []const u8, n: []const u8) bool {
    if (h.len < n.len) return false;
    return indexOfCI(h, n) == 0;
}

pub fn endsWithCI(h: []const u8, n: []const u8) bool {
    if (h.len < n.len) return false;
    return startsWithCI(h[h.len - n.len ..], n);
}

pub fn mapSqlType(alloc: std.mem.Allocator, raw: []const u8) ![]const u8 {
    const t0 = trimWhitespace(raw);

    if (endsWithCI(t0, "[]")) {
        const inner = t0[0 .. t0.len - 2];
        const innerTs = try mapSqlType(alloc, inner);
        return try std.fmt.allocPrint(alloc, "{s}[]", .{innerTs});
    }

    if (startsWithCI(t0, "uuid")) return "string";
    if (startsWithCI(t0, "jsonb") or startsWithCI(t0, "json")) return "any";
    if (startsWithCI(t0, "boolean") or startsWithCI(t0, "bool")) return "boolean";

    if (indexOfCI(t0, "serial") != null) return "number";
    if (indexOfCI(t0, "decimal") != null or indexOfCI(t0, "numeric") != null) return "number";

    if (indexOfCI(t0, "char") != null or indexOfCI(t0, "text") != null) return "string";

    if (indexOfCI(t0, "timestamp") != null or indexOfCI(t0, "date") != null or indexOfCI(t0, "time") != null) return "string";

    return "any";
}

pub fn trimWhitespace(s: []const u8) []const u8 {
    var start: usize = 0;
    var end: usize = s.len;
    while (start < end and isWhitespace(s[start])) start += 1;
    while (end > start and isWhitespace(s[end - 1])) end -= 1;
    return s[start..end];
}

pub fn isColumnDef(s: []const u8) bool {
    const kws = &[_][]const u8{
        "constraint",
        "primary key",
        "foreign key",
        "unique",
        "check",
    };

    for (kws) |kw| {
        if (startsWithCI(s, kw)) return false;
    }

    return true;
}

fn toLower(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
}
fn toUpper(c: u8) u8 {
    return if (c >= 'a' and c <= 'z') c - 32 else c;
}

pub fn removeComments(alloc: std.mem.Allocator, sql: []const u8) anyerror![]u8 {
    var out = try std.ArrayList(u8).initCapacity(alloc, 16);
    var i: usize = 0;
    while (i < sql.len) {
        if (i + 1 < sql.len and sql[i] == '-' and sql[i + 1] == '-') {
            i += 2;
            while (i < sql.len and sql[i] != '\n') i += 1;
        } else if (i + 1 < sql.len and sql[i] == '/' and sql[i + 1] == '*') {
            i += 2;
            while (i + 1 < sql.len and !(sql[i] == '*' and sql[i + 1] == '/')) i += 1;
            if (i + 1 < sql.len) i += 2;
        } else {
            try out.append(alloc, sql[i]);
            i += 1;
        }
    }
    return out.toOwnedSlice(alloc);
}

pub fn isWhitespace(c: u8) bool {
    return switch (c) {
        ' ', '\t', '\n', '\r' => true,
        else => false,
    };
}

pub fn indexOfIgnoreCase(haystack: []const u8, needle: []const u8) ?usize {
    if (haystack.len > needle.len) {
        for (0..haystack.len - needle.len) |i| {
            var matched = true;
            for (0..needle.len) |j| {
                if (toLower(haystack[i + j]) != toLower(needle[j])) {
                    matched = false;
                    break;
                }
            }
            if (matched) return i;
        }
    }

    return null;
}
