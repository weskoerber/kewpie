const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("kewpie", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("lib/root.zig"),
    });

    // Tests
    {
        const test_step = b.step("test", "Run the tests");
        const tests = b.addTest(.{
            .optimize = optimize,
            .target = target,
            .root_source_file = b.path("test/root.zig"),
        });
        tests.root_module.addImport("kewpie", mod);

        const run_tests = b.addRunArtifact(tests);
        test_step.dependOn(&run_tests.step);
    }

    addDocsStep(b, .{ .target = target, .optimize = optimize });
}

fn addDocsStep(b: *std.Build, options: anytype) void {
    const docs_step = b.step("docs", "Emit docs");

    const lib = b.addStaticLibrary(.{
        .name = "mac_address",
        .root_source_file = b.path("lib/root.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });

    const docs_install = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "docs",
        .source_dir = lib.getEmittedDocs(),
    });

    docs_step.dependOn(&docs_install.step);
}
