const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tests = b.option(bool, "Tests", "Build tests [default: false]") orelse false;

    const lib = b.addStaticLibrary(.{
        .name = "intrusive",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath("vendor/move/include");
    lib.addIncludePath("vendor/container_hash/include");
    lib.addIncludePath("vendor/config/include");
    lib.addIncludePath("vendor/describe/include");
    lib.addIncludePath("vendor/assert/include");
    lib.addIncludePath("vendor/static_assert/include");
    lib.addIncludePath("vendor/type_traits/include");
    lib.addIncludePath("include");

    lib.installHeadersDirectory("vendor/move/include", "");
    lib.installHeadersDirectory("vendor/describe/include", "");
    lib.installHeadersDirectory("vendor/container_hash/include", "");
    lib.installHeadersDirectory("vendor/config/include", "");
    lib.installHeadersDirectory("vendor/assert/include", "");
    lib.installHeadersDirectory("vendor/static_assert/include", "");
    lib.installHeadersDirectory("vendor/type_traits/include", "");
    lib.installHeadersDirectory("include", "");

    if (tests) {
        buildTest(b, .{
            .path = "example/doc_auto_unlink.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_any_hook.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_avl_set.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_splay_algorithms.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_treap_algorithms.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_entity.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_slist.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_list.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_set.cpp",
            .lib = lib,
        });
        buildTest(b, .{
            .path = "example/doc_window.cpp",
            .lib = lib,
        });
    }
}

fn buildTest(b: *std.Build, info: BuildInfo) void {
    const test_exe = b.addExecutable(.{
        .name = info.filename(),
        .optimize = info.lib.optimize,
        .target = info.lib.target,
    });
    for (info.lib.include_dirs.items) |include| {
        test_exe.include_dirs.append(include) catch {};
    }
    test_exe.addCSourceFile(info.path, cxxFlags);
    test_exe.linkLibCpp();
    b.installArtifact(test_exe);

    const run_cmd = b.addRunArtifact(test_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(
        b.fmt("{s}", .{info.filename()}),
        b.fmt("Run the {s} test", .{info.filename()}),
    );
    run_step.dependOn(&run_cmd.step);
}

const cxxFlags: []const []const u8 = &.{
    "-Wall",
    "-Wextra",
};

const BuildInfo = struct {
    lib: *std.Build.CompileStep,
    path: []const u8,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.split(u8, std.fs.path.basename(self.path), ".");
        return split.first();
    }
};
