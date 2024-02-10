# Kewpie

A simple query string parser for zig.

## Getting Started

### Prerequisites

- [zig](https://ziglang.org/download) (master)

### Installation

1. Add kewpie as a dependency in your project using Zig's package manager

    ```console
    zig fetch --save git+https://github.com/weskoerber/kewpie.git#main
    ```

2. Add kewpie module to your `build.zig`

    ```zig
    const kewpie = b.dependency("kewpie", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("kewpie", kewpie.module("kewpie"));
    ```

### Usage

- Parse entire query string into a hash map

    ```zig
    const std = @import("std");
    const kewpie = @import("kewpie");

    pub fn main() !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer if (gpa.deinit() != .ok) @panic("leak");

        const uri = std.Uri.parse("https://example.com?hello=world");

        const query_params = try kewpie.parse(gpa.allocator(), uri);
        defer query_params.deinit();

        if (query_params.get("hello")) |value| {
            // `value` holds the value `world`
            // ...
        }
    }
    ```

- Parse the query string into an iterator

    ```zig
    const std = @import("std");
    const kewpie = @import("kewpie");

    pub fn main() !void {
        const uri = std.Uri.parse("https://example.com?hello=world");

        var query_params = try kewpie.iter(uri);
        while (query_params.next()) |param| {
            // `param` holds a QueryParam struct
            // ...
        }
    }
    ```
