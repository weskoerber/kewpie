inner_iterator: TokenIterator(u8, .scalar),

pub fn next(self: *Self) ?QueryParam {
    const field = self.inner_iterator.next() orelse return null;

    var params = mem.splitScalar(u8, field, '=');

    const key = params.first();
    const value = params.next() orelse return null;

    return .{
        .name = key,
        .value = value,
    };
}

pub fn peek(self: *Self) ?QueryParam {
    const field = self.inner_iterator.peek() orelse return null;

    var params = mem.splitScalar(u8, field, '=');

    const key = params.first();
    const value = params.next() orelse return null;

    return .{
        .name = key,
        .value = value,
    };
}

const std = @import("std");
const mem = std.mem;
const testing = std.testing;

const TokenIterator = std.mem.TokenIterator;
const Uri = std.Uri;

const Self = @This();

const QueryParam = struct {
    name: []const u8,
    value: []const u8,
};
