const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;
const Uri = std.Uri;

const ParseError = error{
    Invalid,
};

pub fn parse(ally: Allocator, uri: Uri) !StringHashMap([]const u8) {
    var parsed = StringHashMap([]const u8).init(ally);

    const query = uri.query orelse return parsed;

    var params = mem.tokenizeSequence(u8, query, "&");
    while (params.next()) |param| {
        var field = mem.splitSequence(u8, param, "=");

        const key = field.first();
        const value = field.next();

        if (value) |val| {
            try parsed.put(key, val);
        } else {
            continue;
        }
    }

    return parsed;
}
