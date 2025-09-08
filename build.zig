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
            .root_module = b.createModule(.{
                .root_source_file = b.path("test/root.zig"),
                .optimize = optimize,
                .target = target,
            }),
        });
        tests.root_module.addImport("kewpie", mod);

        const run_tests = b.addRunArtifact(tests);
        test_step.dependOn(&run_tests.step);
    }

    addDocsStep(b, .{ .target = target, .optimize = optimize });
}

fn addDocsStep(b: *std.Build, options: anytype) void {
    const docs_step = b.step("docs", "Emit docs");

    const lib = b.addLibrary(.{
        .name = "kewpie",
        .root_module = b.createModule(.{
            .root_source_file = b.path("lib/root.zig"),
            .optimize = options.optimize,
            .target = options.target,
        }),
    });

    const docs_install = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "docs",
        .source_dir = lib.getEmittedDocs(),
    });

    docs_step.dependOn(&docs_install.step);
}
