const std = @import("std");
const testing = std.testing;

const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const StringHashMap = std.StringHashMap;
const Uri = std.Uri;

const kewpie = @import("kewpie");

test "layup" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?hello=world");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("world", parsed.get("hello").?);
}

test "multiple" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?hello=world&name=chad&num=420");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
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

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "not_a_query_param" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "no_value" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test=");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
}

test "no_value_with_multiple" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?test=&name=chad");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
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

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("", parsed.get("test").?);
}

test "ampersand_only" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com?&");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "empty" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parse("http://example.com");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(0, parsed.count());
}

test "without_scheme" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parseWithoutScheme("test.com/?name=chad");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}

test "path_and_query_only" {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const ally = gpa.allocator();

    const uri = try Uri.parseWithoutScheme("/?name=chad");

    var parsed = try kewpie.QueryParams.parse(ally, uri);
    defer parsed.deinit();

    try testing.expectEqual(1, parsed.count());
    try testing.expectEqualStrings("chad", parsed.get("name").?);
}
