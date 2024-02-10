const std = @import("std");
const testing = std.testing;

const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const Uri = std.Uri;

const kewpie = @import("kewpie");

test "layup" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?hello=world");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("world", parsed.get("hello").?);
}

test "multiple" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?hello=world&name=chad&num=420");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(3, parsed.count());
    try testing.expectEqualStrings("world", parsed.get("hello").?);
    try testing.expectEqualStrings("chad", parsed.get("name").?);
    try testing.expectEqualStrings("420", parsed.get("num").?);
}

test "none" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "not_a_query_param" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "no_value" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test=");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
}

test "no_value_with_multiple" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test=&name=chad");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(2, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}

test "trailing_ampersand" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test=&");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
}

test "ampersand_only" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?&");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "empty" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "without_scheme" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parseWithoutScheme("test.com/?name=chad");

    var parsed = try kewpie.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}

test "path_and_query_only" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parseWithoutScheme("/?name=chad");

    var parsed = try kewpie.parse(ally, uri);
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
