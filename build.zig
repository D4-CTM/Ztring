const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("string", .{
        .root_source_file = b.path("src/string.zig"),
    });

    const lib_test = b.addTest(.{
        .root_source_file = b.path("src/string-tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    const testing = b.step("tests", "Testing if the string is not broken");
    testing.dependOn(lib_test);
}
