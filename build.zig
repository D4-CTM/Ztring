const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

//    const lib_mod = b.createModule(.{
//        .root_source_file = b.path("src/string.zig"),
//        .target = target,
//        .optimize = optimize,
//    });

    _ = b.addModule("string", .{
        .root_source_file = b.path("src/string.zig"),
    });

//    const lib = b.addLibrary(.{
//        .linkage = .static,
//        .name = "string",
//        .root_module = lib_mod,
//    });

    const lib_test = b.addTest(.{
        .root_source_file = "src/string-tests.zig",
        .target = target,
        .optimize = optimize,
    });

//    b.installArtifact(lib);

    const testing = b.step("tests", "Testing if the string is not broken");
    testing.dependOn(lib_test);
}
