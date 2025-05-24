const std = @import("std");
const Str = @import("string.zig");

const String = Str.String;
const StrErr = Str.STRING_ERRORS;

const expect = std.testing.expect;
const expectEqlStr = std.testing.expectEqualStrings;

test "basic String usage test" {
    const testAlloc = std.testing.allocator;
    var str: String = String.init(testAlloc);
    defer str.deinit();

    try str.push_front('a');
    try expect(str.length == 1);

    try str.prepend("ol");
    try expect(str.length == 3);
    try expect(str.getCapacity() == 3);
    try expect(str.equals("ola"));

    try expect(try str.resize(10));

    try str.append(", mundo");
    try expect(str.length == str.getCapacity());
    try expect(str.equals("ola, mundo"));

    try str.push_back('!');
    try expect(str.length == 11);
    try expect(str.equals("ola, mundo!"));

    try str.push_front('H');
    try expect(str.length == 12);
    try expect(str.equals("Hola, mundo!"));

    try expect(try str.resize(20));
    try expect(str.getCapacity() == 20);

    try expect(try str.shrink());
    try expect(str.getCapacity() == str.length);
}

test "String transformation" {
    const testAlloc = std.testing.allocator;
    var str: String = try String.contentInit(testAlloc, "HOLA, MUNDO!");
    defer str.deinit();

    try str.toLowerCase();
    try expect(str.equals("hola, mundo!"));

    try str.toUpperCase();
    try expect(str.equals("HOLA, MUNDO!"));

    try str.decapitalize();
    try expect(str.equals("hOLA, MUNDO!"));

    try str.capitalize();
    try expect(str.equals("HOLA, MUNDO!"));

    try str.prepend("    ");
    try str.append("    ");

    try str.trimStart();
    try expect(str.length == 16);

    try str.trimEnd();
    try expect(str.length == 12);

    try expect(str.equals("HOLA, MUNDO!"));

    try str.prepend("    ");
    try str.append("    ");
    try expect(str.length == 20);

    try str.trim();
    try expect(str.length == 12);
}

test "String slicing" {
    const testAlloc = std.testing.allocator;
    var str: String = try String.contentInit(testAlloc, "HOLA, MUNDO!");
    defer str.deinit();

    try expect(std.mem.eql(u8, str.getStringLiteral(), "HOLA, MUNDO!"));

    const substrlit = try str.sliceLiteral(0, 4);
    try expect(std.mem.eql(u8, substrlit, "HOLA"));

    var strcopy = try str.copy();
    defer strcopy.deinit();
    try expect(strcopy.equalStrings(str));

    const strBefore = try str.getBefore(4);
    try expectEqlStr(strBefore, substrlit);

    const strAfter = try str.getAfter(4);
    try expectEqlStr(strAfter, ", MUNDO!");

    try std.testing.expectError(StrErr.INDEX_OUT_OF_BOUNDS, str.getAfter(1000));
    try std.testing.expectError(StrErr.INDEX_OUT_OF_BOUNDS, str.getBefore(1000));
}

test "String inspection" {
    const testAlloc = std.testing.allocator;
    var str = try String.contentInit(testAlloc, "ola");
    defer str.deinit();

    try expect(try str.contains("hola") == false);

    try str.push_front('h');
    try expect(try str.contains("hola"));
    try expect(try str.contains("holaa") == false);

    try str.append( "HOLA");
    try str.prepend("HOLA hola ");

    try expect(try str.find("hola") == 5);
    try expect(try str.findLast("hola") == 10);
    try expect(try str.find("HOLA") == 0);
    try expect(try str.findLast("HOLA") == 14);
}

test "String splitting" {
    const testAlloc = std.testing.allocator;
    var str = try String.contentInit(testAlloc, "hola|mundo,!!!");
    defer str.deinit();

    var iters = try str.split("|,");
    var idx: u8 = 0;
    _ = &idx;
    while (iters.next()) |iter| {
        switch (idx) {
            0 => try expectEqlStr(iter, "hola"),
            1 => try expectEqlStr(iter, "mundo"),
            2 => try expectEqlStr(iter, "!!!"),
            else => {}
        }
        idx += 1;
    }

    str.clear();
    try expect(str.getCapacity() != 0);

    try str.append("Hola||mundo||!!!,");
    var iters2 = try str.splitSequence("||");
    idx = 0;
    while (iters2.next()) |iter| {
        switch (idx) {
            0 => try expectEqlStr(iter, "Hola"),
            1 => try expectEqlStr(iter, "mundo"),
            2 => try expectEqlStr(iter, "!!!,"),
            else => {}
        }
        idx += 1;
    }

    str.clear();
    try expect(str.getCapacity() != 0);

    try str.append("Hola\nmundo\n!!!");
    var iters3 = try str.getLines();
    idx = 0;
    while (iters3.next()) |iter| {
        switch (idx) {
            0 => try expectEqlStr(iter, "Hola"),
            1 => try expectEqlStr(iter, "mundo"),
            2 => try expectEqlStr(iter, "!!!"),
            else => {}
        }
        idx += 1;
    }

    try expectEqlStr("Hola", try str.forwardGetUntil("\n"));
    try expectEqlStr("!!!", try str.backwardsGetUntil("\n"));
}
