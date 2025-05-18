# Ztring

Library made for fun, it covers some of the basic usage of strings.

| Function names | Description |
| -------------- | --------------- |
| init(Allocator)  | Creates a String struct with a set Allocator. |
| contentInit(Allocator, []const u8)| Creates a String with a set Allocator + initial content. |
| deinit() | Deletes the string instance. |
| getStringLiteral() | Gets the string string stored in the pointer |
| resize(usize) | Increases or decreases the capacity of the string.  |
| getCapacity() | Get's the current capacity of the string. |
| shrink() | Reduces the capacity of the string to the length of itself. |
| isEmpty() | Checks if the string's length is 0. |
| prepend([]const u8) | Add's a string literal at the beginning. |
| push_front(u8) | Add's a single character at the beginning. |
| append([]const u8) | Add's a string literal at the end. |
| push_back(u8) | Add's a single char at the end. |
| charAt(usize) | Get's the value at the specified position. |
| toUpperCase() | Converts the whole string into uppercase. |
| capitalize() | Capitalizes the first letter of the current string. |
| toLowerCase() | Converts the whole string into lowercase. |
| decapitalize() | Decapitalizes the first letter of the current string. |
| equals([]const u8) | Compares a string with a literal. |
| equalStrings(*String) | Compares a string with another string |
| sliceLiteral(start: u8, finish: u8) | Slices the string and returns a slice ([]const u8).
| substring(start: u8, finish u8) | Slices the string and returns another String with set slice. |
| copy() | Makes a copy of the current string. |
| clear() | Set's string length into 0. |
| contains(needle: []const u8) | Find if the needle is found in the `string`. |
| find(needle: []const u8) | Find's the first instance of `needle` in the string. |
| findLast(needle: []const u8) | Finds the last instace of `needle` in the string. |
| split(delimeter: []const u8) | Splits the string based on any char find in the `delimeter`. |
| splitSequence(delimeter: []const u8) | Splits the string based on the char sequence of `delimeter`. |
| getLines() | Makes a split using the `\n` char as delimeter |

