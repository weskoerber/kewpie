const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;
const Uri = std.Uri;

pub const QueryParamIterator = @import("QueryParamIterator.zig");

pub fn parse(ally: Allocator, uri: Uri) Allocator.Error!StringHashMap([]const u8) {
    var parsed = StringHashMap([]const u8).init(ally);

    const query = uri.query orelse return parsed;

    var params = mem.tokenizeScalar(u8, query, '&');
    while (params.next()) |param| {
        var field = mem.splitScalar(u8, param, '=');

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

pub fn iter(uri: Uri) QueryParamIterator {
    return .{
        .inner_iterator = std.mem.tokenizeScalar(u8, uri.query orelse "", '&'),
    };
}
