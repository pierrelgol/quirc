// # quirc -- QR-code recognition library
// # Copyright (C) 2010-2012 Daniel Beer <dlbeer@gmail.com>
// #
// # Permission to use, copy, modify, and/or distribute this software for any
// # purpose with or without fee is hereby granted, provided that the above
// # copyright notice and this permission notice appear in all copies.
// #
// # THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// # WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// # MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// # ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// # WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// # ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// # OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sanitize = b.option(std.zig.SanitizeC, "sanitize_c", "level of C sanitization") orelse .off;

    const mod = b.addModule("quirc", .{
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
        .sanitize_c = sanitize,
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
            "-O3", "-Wall", "-fPIC", "-mtune=native",
        },
        .language = .c,
    });
    const quirc_header = b.addInstallHeaderFile(
        b.path("src/quirc.h"),
        "quirc.h",
    );

    const quirc_internal_header = b.addInstallHeaderFile(
        b.path("src/quirc_internal.h"),
        "quirc_internal.h",
    );

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
