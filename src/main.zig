const std = @import("std");

pub fn main() !void {
    var stdout_buffer: [256]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("clearing...\n", .{});
    try stdout.flush();

    // Use ANSI escape codes which work on:
    // - Linux/Unix terminals
    // - macOS terminals
    // - Windows 10+ (with VT100 support enabled by default)
    // - Windows Terminal

    // Clear screen and move cursor to top-left
    try stdout.print("\x1B[2J\x1B[H", .{});
    try stdout.flush();

    // Alternative method for older Windows systems:
    if (@import("builtin").os.tag == .windows) {
        const windows = std.os.windows;
        const kernel32 = windows.kernel32;
    
        const stdout_handle = try std.os.windows.GetStdHandle(std.os.windows.STD_OUTPUT_HANDLE);
    
        var csbi: windows.CONSOLE_SCREEN_BUFFER_INFO = undefined;
        if (kernel32.GetConsoleScreenBufferInfo(stdout_handle, &csbi) == 0) {
            return error.GetConsoleInfoFailed;
        }
    
        const console_size = @as(u32, @intCast(csbi.dwSize.X)) * @as(u32, @intCast(csbi.dwSize.Y));
        const coord = windows.COORD{ .X = 0, .Y = 0 };
        var written: u32 = 0;
    
        _ = kernel32.FillConsoleOutputCharacterA(stdout_handle, ' ', console_size, coord, &written);
        _ = kernel32.FillConsoleOutputAttribute(stdout_handle, csbi.wAttributes, console_size, coord, &written);
        _ = kernel32.SetConsoleCursorPosition(stdout_handle, coord);
    }
}
