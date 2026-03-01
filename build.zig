const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("quirc", .{
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.addIncludePath(b.path("src/"));
    mod.addCSourceFiles(.{
        .root = b.path("src/"),
        .files = &.{
            "decode.c",
            "identify.c",
            "quirc.c",
            "version_db.c",
        },
        .flags = &.{
            "-O3", "-Wall", "-fPIC",
        },
        .language = .c,
    });
    const quirc_header = b.addInstallHeaderFile(b.path("src/quirc.h"), "quirc.h");
    const quirc_internal_header = b.addInstallHeaderFile(b.path("src/quirc_internal.h"), "quirc_internal.h");

    const lib = b.addLibrary(.{
        .name = "quirc",
        .root_module = mod,
    });
    lib.step.dependOn(&quirc_internal_header.step);
    lib.step.dependOn(&quirc_header.step);
    b.installArtifact(lib);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
