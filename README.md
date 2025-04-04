[![test](https://github.com/weskoerber/kewpie/actions/workflows/test.yaml/badge.svg)](https://github.com/weskoerber/kewpie/actions/workflows/test.yaml)
[![docs](https://github.com/weskoerber/kewpie/actions/workflows/docs.yaml/badge.svg)](https://github.com/weskoerber/kewpie/actions/workflows/docs.yaml)

# Kewpie

A simple query string parser for zig.

## Getting Started

### Prerequisites

- [Zig](https://ziglang.org/download) (`0.14.0` or newer)
    - If using Zig `0.12` and `0.13`, use the [`zig-0.12`](https://github.com/weskoerber/kewpie/tree/zig-0.12) branch

### Installation

1. Add kewpie as a dependency in your project using Zig's package manager

    ```console
    zig fetch --save git+https://github.com/weskoerber/kewpie.git#0.1.1
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

        const uri = try std.Uri.parse("https://example.com?hello=world");

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
        const uri = try std.Uri.parse("https://example.com?hello=world");

        var query_params = kewpie.iter(uri);
        while (query_params.next()) |param| {
            // `param` holds a QueryParam struct
            // ...
        }
    }
    ```
