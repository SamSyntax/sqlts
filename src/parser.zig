const std = @import("std");
const types = @import("types.zig");
const utils = @import("utils.zig");

pub fn parseSchema(alloc: std.mem.Allocator, sql: []const u8) !std.ArrayList(types.Table) {
    var tables = try std.ArrayList(types.Table).initCapacity(alloc, 8);

    var pos: usize = 0;

    while (true) {
        const rel = utils.indexOfIgnoreCase(sql[pos..], "create table");
        if (rel == null) break;
        const rel_i = rel.?;
        const ct_idx = pos + rel_i;
        var idx = ct_idx + "create table".len;

        while (idx < sql.len and utils.isWhitespace(sql[idx])) idx += 1;
        if (idx >= sql.len) break;

        var table_name: []const u8 = undefined;
        if (sql[idx] == '"' and !std.mem.eql(u8, sql[idx .. idx + 13], "IF NOT EXISTS")) {
            idx += 1;
            const start = idx;
            while (idx < sql.len and sql[idx] != '"') idx += 1;
            table_name = sql[start..idx];
            idx += 1;
        } else {
            if (std.mem.eql(u8, sql[idx .. idx + 14], "IF NOT EXISTS ")) {
                idx += 14;
            }
            const start = idx;
            while (idx < sql.len and !utils.isWhitespace(sql[idx]) and sql[idx] != '(') {
                idx += 1;
            }
            table_name = sql[start..idx];
        }

        while (idx < sql.len and sql[idx] != '(') idx += 1;
        if (idx >= sql.len) break;
        const open_idx = idx;
        idx += 1;

        var depth: usize = 1;
        var j: usize = idx;
        while (j < sql.len and depth > 0) {
            if (sql[j] == '(') {
                depth += 1;
            } else if (sql[j] == ')') {
                depth -= 1;
            }
            j += 1;
        }
        if (depth != 0) break;
        const close_idx = j - 1;
        const block = sql[open_idx + 1 .. close_idx];

        var cols = try std.ArrayList(types.Column).initCapacity(alloc, 8);
        var start: usize = 0;
        depth = 0;
        for (block, 0..) |c, i| {
            if (c == '(') {
                depth += 1;
            } else if (c == ')') {
                depth -= 1;
            } else if (c == ',') {
                if (depth == 0) {
                    const def = utils.trimWhitespace(block[start..i]);
                    if (utils.isColumnDef(def)) {
                        const col = try parseColumn(alloc, def);
                        try cols.append(alloc, col);
                    }
                    start = i + 1;
                }
            }
        }
        if (start < block.len) {
            const def = utils.trimWhitespace(block[start..]);
            if (utils.isColumnDef(def)) {
                const col = try parseColumn(alloc, def);
                try cols.append(alloc, col);
            }
        }

        const ts_name = try utils.toCamelCase(alloc, table_name, true);
        const t = types.Table{
            .name = table_name,
            .ts_name = ts_name,
            .columns = cols,
        };
        try tables.append(alloc, t);
        pos = close_idx + 1;
    }
    return tables;
}

fn parseColumn(alloc: std.mem.Allocator, def: []const u8) !types.Column {
    var idx: usize = 0;
    var name: []const u8 = undefined;

    if (def[0] == '"') {
        idx = 1;
        const st = idx;
        while (idx < def.len and def[idx] != '"') idx += 1;
        name = def[st..idx];
        idx += 1;
    } else {
        const st = idx;
        while (idx < def.len and !utils.isWhitespace(def[idx])) {
            idx += 1;
        }
        name = def[st..idx];
    }

    while (idx < def.len and utils.isWhitespace(def[idx])) {
        idx += 1;
    }
    const type_start = idx;

    var depth: usize = 0;
    var type_end = def.len;
    while (idx < def.len) {
        const c = def[idx];
        if (c == '(') {
            depth += 1;
        } else if (c == ')') {
            depth -= 1;
        } else if (utils.isWhitespace(c) and depth == 0) {
            type_end = idx;
            break;
        }
        idx += 1;
    }

    const sql_type = def[type_start..type_end];

    const hasNotNull = utils.indexOfCI(def, "not null") != null;
    const hasPK = utils.indexOfCI(def, "primary key") != null;
    const is_nullable = !(hasNotNull or hasPK);

    const ts_name = try utils.toCamelCase(alloc, name, false);

    return types.Column{
        .name = name,
        .ts_name = ts_name,
        .sql_type = sql_type,
        .ts_type = try utils.mapSqlType(alloc, sql_type),
        .is_nullable = is_nullable,
    };
}

pub fn emitTsFile(tables: std.ArrayList(types.Table), outPath: []const u8, asInterface: bool) !void {
    const cwd = std.fs.cwd();
    var file = try cwd.createFile(outPath, .{ .truncate = false });
    defer file.close();

    var tskeytype: []const u8 = undefined;

    if (asInterface) {
        tskeytype = "interface ";
    } else {
        tskeytype = "type ";
    }

    for (tables.items) |table| {
        try file.writeAll("export ");
        try file.writeAll(tskeytype);
        try file.writeAll(table.ts_name);
        try file.writeAll(" = ");
        try file.writeAll(" {\n");
        for (table.columns.items) |col| {
            if (col.is_nullable) {
                try file.writeAll("  ");
                try file.writeAll(col.ts_name);
                try file.writeAll("?: ");
                try file.writeAll(col.ts_type);
                try file.writeAll(" | null;\n");
            } else {
                try file.writeAll("  ");
                try file.writeAll(col.ts_name);
                try file.writeAll(": ");
                try file.writeAll(col.ts_type);
                try file.writeAll(";\n");
            }
        }
        try file.writeAll("}\n\n");
    }
}
