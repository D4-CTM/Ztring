const std = @import("std");
const allocator = std.mem.Allocator;
pub const splitIterAny = std.mem.SplitIterator(u8, .any);
pub const splitIterSeq = std.mem.SplitIterator(u8, .sequence);

pub const STRING_ERRORS = error {
    INDEX_OUT_OF_BOUNDS,
    /// This error could mean that the string wasn't initialized or
    /// that it is empty.
    STRING_NOT_INITIALIZED,
    STRING_CANNOT_REALLOC,
};

pub const String = struct {
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
        if (self.str) |*str| return str.len;
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

    /// Add's a single character at the beginning of the string.
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

    /// Finds first instance of `needle` in the string.
    pub fn find(self: *String, needle: []const u8) STRING_ERRORS!?usize{
        if (self.str) |*str| {
            return std.mem.indexOf(u8, str.*, needle);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Finds last instance of `needle` in the string.
    pub fn findLast(self: *String, needle: []const u8) STRING_ERRORS!?usize{
        if (self.str) |*str| {
            return std.mem.lastIndexOf(u8, str.*, needle);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    pub fn contains(self: *String, needle: []const u8) STRING_ERRORS!bool {
        if (self.str) |*str| {
            return std.mem.containsAtLeast(u8, str.*, 1, needle);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Assuming we have a string like: "abc,def||ghi"
    /// when calling for `split("|,")` will return an
    /// iterator with `"abc", "def", "", "ghi", null`, in 
    /// that order as `[]const u8`.
    ///
    /// If none of `delimiters` exist in buffer,
    /// the iterator will return the string and null, in that order.
    pub fn split(self: *String, delimeter: []const u8) STRING_ERRORS!splitIterAny {
        if (self.str) |str| {
           return  std.mem.splitAny(u8, str[0..self.length], delimeter);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Assuming we have a string like: "abc||def||||ghi"
    /// when calling `splitSequence("||")` will return an
    /// iterator with `"abc", "def", "", "ghi", null`, in 
    /// that order as `[]const u8`.
    ///
    /// If `delimiter` does not exist in the string,
    /// the iterator will return the string and null, 
    /// in that order.
    pub fn splitSequence(self: *String, delimeter: []const u8) STRING_ERRORS!splitIterSeq {
        if (self.str) |str| {
           return std.mem.splitSequence(u8, str.ptr[0..self.length], delimeter);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Split's the string using the `\n` scape key.
    pub fn getLines(self: *String) STRING_ERRORS!splitIterAny {
        return self.split("\n");
    }

    /// Get's string value until the first instance of ``delimeter``,
    /// starting from the beginning of the string.
    ///
    /// If we had a string like: "Hello world!" and we called for:
    /// getUntil(" "); our output should be simply: "Hello".
    /// If the ``delimeter`` wasn't found it will return the whole string.
    pub fn forwardGetUntil(self: *String, delimeter: []const u8) STRING_ERRORS![]const u8 {
        if (self.str) |*str| {
            const idx = try self.find(delimeter) orelse self.length;
            return str.ptr[0..idx];
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Get's string value until the first instance of ``delimeter``,
    /// starting from the end of the string.
    ///
    /// If we had a string like: "Hello world!" and we called for:
    /// getUntil(" "); our output should be simply: "world!".
    /// If the ``delimeter`` wasn't found it will return the whole string.
    pub fn backwardsGetUntil(self: *String, delimeter: []const u8) STRING_ERRORS![]const u8 {
        if (self.str) |*str| {
            var idx = try self.findLast(delimeter) orelse 0;
            
            if (idx > 0) idx += 1;

            return str.ptr[idx..self.length];
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

    /// Returns the string stored on the pointer.
    /// Silently fails returning an empty string (`""`) if the pointer is empty.
    pub fn getStringLiteral(self: *String) []const u8 {
        if (self.str) |*str| return str.ptr[0..self.length];
        return "";
    }
    
    /// Get's the string literal starting from ``start`` position till the end.
    pub fn getAfter(self: *String, start: usize) STRING_ERRORS![]const u8 {
        if (self.length <= start) return STRING_ERRORS.INDEX_OUT_OF_BOUNDS;

        if (self.str) |*str| {
           return str.ptr[start..self.length]; 
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Get's the string literal starting from position 0 till the ``limit``.
    pub fn getBefore(self: *String, limit: usize) STRING_ERRORS![]const u8 {
        if (self.length < limit) return STRING_ERRORS.INDEX_OUT_OF_BOUNDS;

        if (self.str) |*str| {
           return str.ptr[0..limit]; 
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

    /// Makes a copy of the current string.
    pub fn copy(self: *String) STRING_ERRORS!String {
        if (self.str) |*str| {
            return String.contentInit(self.alloc, str.*);
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Old memory remains, simply changes the length into 0
    pub fn clear(self: *String) void {
        self.length = 0;
    }

    /// Removes the white spaces from the beginning.
    pub fn trimStart(self: *String) STRING_ERRORS!void{
        if (self.str) |*str| {
            var idx: usize = 0;
            while (str.*[idx] == ' ') {
                idx += 1;
            }
            std.mem.copyForwards(u8, str.ptr[0..self.length-idx], str.ptr[idx..self.length]);
            self.length -= idx;
            return ;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Removes the white spaces from the end.
    pub fn trimEnd(self: *String) STRING_ERRORS!void{
        if (self.str) |*str| {
            var idx: usize = self.length;
            while (str.*[idx - 1] == ' ') {
                idx -= 1;
            }
            self.length = idx;
            return ;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Removes the white spaces from both the beginning and the end.
    pub fn trim(self: *String) STRING_ERRORS!void{
        if (self.str) |_| {
            try self.trimStart();
            try self.trimEnd();
            return ;
        }
        return STRING_ERRORS.STRING_NOT_INITIALIZED;
    }

    /// Compares our string with a string literal.
    pub fn equals(self: *String, compare_str: []const u8) bool {
        if (self.str) |*str| {
            return std.mem.eql(u8, str.ptr[0..self.length], compare_str);
        }
        return false;
    }

    /// Compare our string with another string.
    pub fn equalStrings(self: *String, compare_str: String) bool {
        if (compare_str.str) |*str| {
            return self.equals(str.ptr[0..compare_str.length]);
        }
        return false;
    }
};
