const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "kewpie",
        .optimize = optimize,
        .target = target,
        .root_source_file = .{ .path = "./lib/root.zig" },
    });

    const lib_shared = b.addSharedLibrary(.{
        .name = "kewpie",
        .optimize = optimize,
        .target = target,
        .root_source_file = .{ .path = "./lib/root.zig" },
        .version = std.SemanticVersion{
            .major = 0,
            .minor = 1,
            .patch = 0,
        },
    });

    b.installArtifact(lib);
    b.installArtifact(lib_shared);

    const mod = b.addModule("kewpie", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "./lib/root.zig" },
    });

    // Tests
    const test_step = b.step("test", "Run the tests");
    const tests = b.addTest(.{
        .optimize = optimize,
        .target = target,
        .root_source_file = .{ .path = "./test/root.zig" },
    });

    tests.root_module.addImport("kewpie", mod);

    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);
}
