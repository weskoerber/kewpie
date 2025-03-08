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
    const test_step = b.step("test", "Run the tests");
    const tests = b.addTest(.{
        .root_module = mod,
    });

    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);

    addDocsStep(b, mod);
}

fn addDocsStep(b: *std.Build, root_module: *std.Build.Module) void {
    const docs_step = b.step("docs", "Emit docs");

    const lib = b.addLibrary(.{
        .name = "mac_address",
        .root_module = root_module,
    });

    const docs_install = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "docs",
        .source_dir = lib.getEmittedDocs(),
    });

    docs_step.dependOn(&docs_install.step);
}
