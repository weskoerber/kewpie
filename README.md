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
