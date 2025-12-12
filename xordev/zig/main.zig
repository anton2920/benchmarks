const std = @import("std");

const vec2 = @Vector(2, f32);
const vec4 = @Vector(4, f32);
const int  = i32;

const WIDTH  = 800;
const HEIGHT = 600;

pub fn dot(self: vec2, other: vec2) f32 {
	return self[0] * other[0] + self[1] * other[1];
}

pub fn tanh4(v: vec4) vec4 {
	return (@exp(@as(vec4, @splat(2))*v) - @as(vec4, @splat(1))) / (@exp(@as(vec4, @splat(2))*v) + @as(vec4, @splat(1)));
}

const tanh = tanh4;

pub fn Shader(pixels: []u32, width: i32, height: i32, t: f32) void {
	const r: vec2 = .{@floatFromInt(width), @floatFromInt(height)};
	for (0..@intCast(height)) |y| {
		for (0..@intCast(width)) |x| {
			var o: vec4 = @splat(0);
			const FC: vec2 = .{@floatFromInt(x), @floatFromInt(@as(usize, @intCast(height)) - y)};

			var i: vec2 = @splat(0);
			const p: vec2 = (FC * @as(vec2, @splat(2)) - r) / @as(vec2, @splat(r[1]));
			const l: vec2 = @as(vec2, @splat(4 - 4 * @abs(0.7 - dot(p, p))));
			var v: vec2 = p * @as(vec2, @splat(l[0]));

			while (i[1] < 8.0) : (o += (@sin(@as(vec4, .{v[0], v[1], v[1], v[0]})) + @as(vec4, @splat(1.0))) * @as(vec4, @splat(@abs(v[0] - v[1])))) {
				i[1] += 1;
				v += @cos(@as(vec2, .{v[1], v[0]}) * @as(vec2, @splat(i[1])) + i + @as(vec2, @splat(t))) / @as(vec2, @splat(i[1])) + @as(vec2, @splat(0.7));
			}
			o = tanh(@as(vec4, @splat(5.0)) * @exp(@as(vec4, @splat(l[0] - 4.0)) - @as(vec4, @splat(p[1])) * @as(vec4, .{-1, 1, 2, 0})) / o);

			{
				@setRuntimeSafety(false);
				pixels[y * @as(usize, @intCast(width)) + x] = @as(u32, @intFromFloat(o[0]*255)) << 24 | @as(u32, @intFromFloat(o[1]*255)) << 16 | @as(u32, @intFromFloat(o[2]*255)) << 8;
			}
		}
	}
}

pub fn DumpPPM(filepath: []const u8, pixels: []u32, width: int, height: int) !void {
    var out = try std.fs.cwd().createFile(filepath, .{});
    defer out.close();

	var writer = out.writer();
	try writer.print("P6 {d} {d} 255 ", .{width, height});
	for (0..@as(usize, @intCast(width*height))) |i| {
		const pixel: u32 = pixels[i];
		try out.writeAll(&[_]u8{@as(u8, @intCast((pixel >> 24) & 0xFF)), @as(u8, @intCast((pixel >> 16) & 0xFF)), @as(u8, @intCast((pixel >> 8) & 0xFF))});
	}

	return;
}

pub fn CyclesToSeconds(cycles: u64) f32 {
	return @as(f32, @floatFromInt(cycles)) / 4000000000;
}

pub inline fn rdtsc() u64 {
    var hi: u32 = 0;
    var low: u32 = 0;

    asm (
        \\rdtsc
        : [low] "={eax}" (low),
          [hi] "={edx}" (hi),
    );
    return (@as(u64, hi) << 32) | @as(u64, low);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
	const pixels: []u32 = try allocator.alloc(u32, WIDTH*HEIGHT);

	var fi: f32 = 0;
	const count = 10;
	var totalFrameTime: u64 = 0;
	for (0..count) |_| {
		const start: u64 = rdtsc();
		Shader(pixels, WIDTH, HEIGHT, fi);
		const end: u64 = rdtsc();
		totalFrameTime += end - start;
		fi += 1;
	}

	const frameTime: f32 = CyclesToSeconds(@as(u64, @intFromFloat(@as(f64, @floatFromInt(totalFrameTime))/@as(f64, @floatFromInt(count)))))*1000;
	std.debug.print("Took {d:.6} s to render {d} frames (Avg: {d:.6}, FPS: {d})\n", .{CyclesToSeconds(totalFrameTime), count, frameTime, 1000 / frameTime});

	Shader(pixels, WIDTH, HEIGHT, 0);
	try DumpPPM("image.ppm", pixels, WIDTH, HEIGHT);
}
