const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;
const Uri = std.Uri;

pub const QueryParamIterator = @import("QueryParamIterator.zig");

/// Takes a `Uri` and attempts to parse the query parameter part into a
/// `StringHashMap`. This function allocates the hash map, so the caller must
/// free the returned memory after use.
pub fn parse(ally: Allocator, uri: Uri) Allocator.Error!StringHashMap([]const u8) {
    var parsed = StringHashMap([]const u8).init(ally);

    const query = if (uri.query) |query| switch (query) {
        .raw => query.raw,
        .percent_encoded => query.percent_encoded,
    } else return parsed;

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

/// Takes a `Uri` and returns a `QueryParamIterator`.
pub fn iter(uri: Uri) QueryParamIterator {
    const query = if (uri.query) |query| switch (query) {
        .raw => query.raw,
        .percent_encoded => query.percent_encoded,
    } else "";

    return .{
        .inner_iterator = std.mem.tokenizeScalar(u8, query, '&'),
    };
}
