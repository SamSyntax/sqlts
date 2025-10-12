const Build = @import("std").Build;

pub fn build(b: *Build) void {
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sqlts",
        .root_module = lib_mod,
    });

    const lib_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_tests.step);
}
