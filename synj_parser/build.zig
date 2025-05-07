const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "synj",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    const header_install = b.addInstallFile(.{
        .src_path = .{
            .sub_path = "includes/synj.h",
            .owner = b,
        },
    }, "include/synj.h");
    b.getInstallStep().dependOn(&header_install.step);

    const tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Run SYNJ parser tests").dependOn(&run_tests.step);
}
