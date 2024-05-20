/// The inner iterator
inner_iterator: TokenIterator(u8, .scalar),

/// Returns a slice of the current token, or null if tokenization is
/// complete, and advances to the next token.
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

/// Returns a slice of the current token, or null if tokenization is
/// complete. Does not advance to the next token.
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

/// A structure representing a query parameter.
const QueryParam = struct {
    /// The name of the query parameter.
    name: []const u8,

    /// The value of the query parameter.
    value: []const u8,
};
