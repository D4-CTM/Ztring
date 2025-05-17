const std = @import("std");
const allocator = std.mem.Allocator;
const expect = std.testing.expect;

const STRING_ERRORS = error {
    INDEX_OUT_OF_BOUNDS,
    STRING_NOT_INITIALIZED,
    STRING_CANNOT_REALLOC,
};

const String = struct {
    alloc: allocator,
    /// The string pointer itself. In here we can find:
    /// ``String capacity`` as len.
    /// "``String``" as the ptr.
    str: ?[]u8,
    /// The length of the string, do not confuse with
    /// it's capacity!
    length: usize,

    pub fn init(alloc: allocator) String {
        return String{
            .alloc = alloc,
            .str = null,
            .length = 0
        };
    }

    pub fn contentInit(alloc: allocator, content: []const u8) STRING_ERRORS!String {
        var string = String.init(alloc);
        try string.append(content);
        return string;
    }

    pub fn deinit(self: *String) void {
        if (self.str) |str| self.alloc.free(str);
        self.length = 0;
    }

    /// Changes the string capacity to the ``desire_capacity``.
    pub fn resize(self: *String, desire_capacity: usize) STRING_ERRORS!bool {
        if (self.str) |_| {
            self.str = self.alloc.realloc(self.str.?, desire_capacity) catch {
                return STRING_ERRORS.STRING_CANNOT_REALLOC;
            };
            return true;
        }

        self.str = self.alloc.alloc(u8, desire_capacity) catch {
            return STRING_ERRORS.STRING_CANNOT_REALLOC;
        };
        return self.str.?.len == desire_capacity;
    }

    /// Shrinks the string capacity into the string's lenght
    pub fn shrink(self: *String) STRING_ERRORS!bool {
        return self.resize(self.length);
    }

    pub fn isEmpty(self: *String) bool {
        return self.length == 0;
    }

    pub fn getCapacity(self: *String) usize {
        if (self.str) |str| return str.len;
        return 0;
    }

    /// Add's a string literal at the beginnig of the current string.
    pub fn prepend(self: *String, add_str: []const u8) STRING_ERRORS!void {
        const str_capacity = self.getCapacity();
        const new_str_len = add_str.len;
        const new_len = self.length + new_str_len;
        if (str_capacity < new_len) {
            _ = self.resize(@max(str_capacity*2, new_len)) catch |err| return err;
        }

        if (self.str) |*str| {
            std.mem.copyBackwards(u8, str.ptr[new_str_len..str.len], str.ptr[0..self.length]);
            @memcpy(str.ptr[0..new_str_len], add_str);
            self.length = new_len;
            return ;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Add's a single character at the beggining of the string.
    ///
    /// Might trigger a resize by 1, depending on the current capacity.
    pub fn push_front(self: *String, char: u8) STRING_ERRORS!void {
        const str_len = self.length;
        if (str_len == self.getCapacity()) {
            _ = self.resize(str_len + 1) catch |err| return err;
        }

        if (self.str) |*str| {
            if (str_len > 1) {
                std.mem.copyBackwards(u8, str.ptr[1..str_len + 1], str.ptr[0..str_len]);
            }
            str.ptr[0] = char;
            self.length += 1;
            return ; 
        }

        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Add's a string literal at the end of the current string.
    pub fn append(self: *String, add_str: []const u8) STRING_ERRORS!void {
        const str_capacity = self.getCapacity();
        const new_length = self.length + add_str.len;
        if (str_capacity < new_length) {
            _ = self.resize(@max(str_capacity*2, new_length)) catch |err| return err;
        }

        if (self.str) |*str| {
            @memcpy(str.ptr[self.length..new_length], add_str);
            self.length = new_length;
            return ;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Add's a single character at the end of the string
    ///
    /// Might trigger a resize by 1, depending on the current capacity.
    pub fn push_back(self: *String, char: u8) STRING_ERRORS!void {
        if (self.length == self.getCapacity()) {
            _ = self.resize(self.length + 1) catch |err| return err;
        }

        if (self.str) |*str| {
            str.ptr[self.length] = char;
            self.length += 1;
            return ;
        }

        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Get's the character at an specific point of the string
    pub fn charAt(self: *String, idx: usize) STRING_ERRORS!u8 {
        if (idx >= self.length) {
           return STRING_ERRORS.INDEX_OUT_OF_BOUNDS; 
        }
        if (self.str) |*str| {
            return str.ptr[idx];
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Converts the current string into lower case.
    pub fn toLowerCase(self: *String) STRING_ERRORS!void {
        if (self.str) |*str| {
            const delta = 'a' - 'A';
            var char: u8 = 0;
            for (0..self.length) |idx| {
                char = str.ptr[idx];
                // if uppercase
                if (char >= 'A' and char <= 'Z') {
                    str.ptr[idx] = char + delta;
                }
            }
            return;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Converts the current string into upper case.
    pub fn toUpperCase(self: *String) STRING_ERRORS!void {
        if (self.str) |*str| {
            const delta = 'a' - 'A';
            var char: u8 = 0;
            for (0..self.length) |idx| {
                char = str.ptr[idx];
                // if lowercase
                if (char >= 'a' and char <= 'z') {
                    str.ptr[idx] = char - delta;
                }
            }
            return;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Capitalizes the current string.
    pub fn capitalize(self: *String) STRING_ERRORS!void {
        if (self.str) |*str| {
            const delta = 'a' - 'A';
            const char: u8 = str.ptr[0];
            // if lowercase
            if (char >= 'a' and char <= 'z') {
                str.ptr[0] = char - delta;
            }
            return;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// decapitalizes the current string.
    ///
    /// Function made for fun, cause why not, yk.
    pub fn decapitalize(self: *String) STRING_ERRORS!void {
        if (self.str) |*str| {
            const delta = 'a' - 'A';
            const char: u8 = str.ptr[0];
            // if uppercase
            if (char >= 'A' and char <= 'Z') {
                str.ptr[0] = char + delta;
            }
            return;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Extract a slice of the string as a char array. 
    ///
    /// Starts at 0, finishes at the string length.
    pub fn sliceLiteral(self: *String, start: usize, finish: usize) STRING_ERRORS![]const u8{
        if (finish > self.length) {
            return STRING_ERRORS.INDEX_OUT_OF_BOUNDS;
        }

        if (self.str) |*str| {
            return str.ptr[start..finish];
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Extract a slice of the string as another string object. 
    ///
    /// Starts at 0, finishes at the string length.
    pub fn substring(self: *String, start: usize, finish: usize) STRING_ERRORS!String{
        if (finish > self.length) {
            return STRING_ERRORS.INDEX_OUT_OF_BOUNDS;
        }

        if (self.str) |*str| {
            return String.contentInit(self.alloc, str.ptr[start..finish]);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Compares our string with a string literal
    pub fn equals(self: *String, compare_str: []const u8) bool {
        if (self.str) |str| {
            return std.mem.eql(u8, str[0..self.length], compare_str);
        }
        return false;
    }
};

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
}

test "String slicing" {
    const testAlloc = std.testing.allocator;
    var str: String = try String.contentInit(testAlloc, "HOLA, MUNDO!");
    defer str.deinit();

    const substrlit = try str.sliceLiteral(0, 4);
    try expect(std.mem.eql(u8, substrlit, "HOLA"));

    var substr = try str.substring(0, 4);
    defer substr.deinit();
    try expect(substr.equals("HOLA"));
}
