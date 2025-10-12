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

pub fn mapSqlType(s: []const u8) []const u8 {
    if (std.mem.indexOf(u8, s, "int") != null) return "number";
    if (std.mem.indexOf(u8, s, "serial") != null) return "number";
    if (std.mem.indexOf(u8, s, "char") != null) return "string";
    if (std.mem.indexOf(u8, s, "text") != null) return "string";
    if (std.mem.indexOf(u8, s, "uuid") != null) return "string";
    if (std.mem.indexOf(u8, s, "bool") != null) return "boolean";
    if (std.mem.indexOf(u8, s, "json") != null) return "any";
    if (std.mem.indexOf(u8, s, "timestamp") != null or std.mem.indexOf(u8, s, "date") != null or std.mem.indexOf(u8, s, "time") != null) return "string";
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

fn startsWithCI(s: []const u8, kw: []const u8) bool {
    if (s.len < kw.len) return false;
    for (kw, 0..) |c, i| {
        if (toLower(c) != c and toLower(c) != toLower(s[i])) return false;
        if (toLower(s[i]) != toLower(c)) return false;
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

    return null;
}
