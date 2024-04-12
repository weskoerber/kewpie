const std = @import("std");
const testing = std.testing;

const Uri = std.Uri;

const kewpie = @import("kewpie");

test "layup" {
    const uri = try Uri.parse("http://example.com?hello=world");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("world", parsed.get("hello").?);
}

test "multiple" {
    const uri = try Uri.parse("http://example.com?hello=world&name=chad&num=420");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(3, parsed.count());
    try testing.expectEqualStrings("world", parsed.get("hello").?);
    try testing.expectEqualStrings("chad", parsed.get("name").?);
    try testing.expectEqualStrings("420", parsed.get("num").?);
}

test "none" {
    const uri = try Uri.parse("http://example.com?");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "not_a_query_param" {
    const uri = try Uri.parse("http://example.com?test");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "no_value" {
    const uri = try Uri.parse("http://example.com?test=");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
}

test "no_value_with_multiple" {
    const uri = try Uri.parse("http://example.com?test=&name=chad");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(2, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}

test "trailing_ampersand" {
    const uri = try Uri.parse("http://example.com?test=&");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
}

test "ampersand_only" {
    const uri = try Uri.parse("http://example.com?&");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "empty" {
    const uri = try Uri.parse("http://example.com");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "without_scheme" {
    const uri = try Uri.parseWithoutScheme("test.com/?name=chad");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}

test "path_and_query_only" {
    const uri = try Uri.parseWithoutScheme("/?name=chad");

    var parsed = try kewpie.parse(testing.allocator, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}

test "iterator_1" {
    const uri = try Uri.parse("https://example.com?hello=world");
    var it = kewpie.iter(uri);

    try testing.expect(it.next() != null);
}

test "iterator_many" {
    const uri = try Uri.parse("http://example.com?hello=world&name=chad&num=420");
    var it = kewpie.iter(uri);

    var field = it.next().?;
    try testing.expectEqualStrings("hello", field.name);
    try testing.expectEqualStrings("world", field.value);

    field = it.next().?;
    try testing.expectEqualStrings("name", field.name);
    try testing.expectEqualStrings("chad", field.value);

    field = it.next().?;
    try testing.expectEqualStrings("num", field.name);
    try testing.expectEqualStrings("420", field.value);
}

test "iterator_peek" {
    const uri = try Uri.parse("http://example.com?hello=world&name=chad&num=420");
    var it = kewpie.iter(uri);

    var field = it.next().?;
    try testing.expectEqualStrings("hello", field.name);
    try testing.expectEqualStrings("world", field.value);

    field = it.peek().?;
    try testing.expectEqualStrings("name", field.name);
    try testing.expectEqualStrings("chad", field.value);

    field = it.next().?;
    try testing.expectEqualStrings("name", field.name);
    try testing.expectEqualStrings("chad", field.value);

    field = it.next().?;
    try testing.expectEqualStrings("num", field.name);
    try testing.expectEqualStrings("420", field.value);
}

test "iterator_many_with_invalid" {
    const uri = try Uri.parse("http://example.com?hello=world&name=&num=420");
    var it = kewpie.iter(uri);

    var field = it.next().?;
    try testing.expectEqualStrings("hello", field.name);
    try testing.expectEqualStrings("world", field.value);

    field = it.next().?;
    try testing.expectEqualStrings("name", field.name);
    try testing.expectEqualStrings("", field.value);

    field = it.next().?;
    try testing.expectEqualStrings("num", field.name);
    try testing.expectEqualStrings("420", field.value);
}

comptime {
    testing.refAllDecls(@This());
    testing.refAllDecls(kewpie);
    testing.refAllDecls(kewpie.QueryParamIterator);
}
