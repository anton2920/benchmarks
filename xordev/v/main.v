import math
import math.vec
import os

const width = 800
const height = 600

type Vec2 = vec.Vec2[f32]
type Vec4 = vec.Vec4[f32]

@[inline]
fn vec2(x f32) Vec2 {
	return Vec2{x, x}
}

@[inline]
fn cos2(v Vec2) Vec2 {
	return Vec2{math.cosf(v.x), math.cosf(v.y)}
}

@[inline]
fn (v Vec2) yx() Vec2 {
	return Vec2{v.y, v.x}
}

@[inline]
fn (v Vec2) xyyx() Vec4 {
	return Vec4{v.x, v.y, v.y, v.x}
}

@[inline]
fn vec4(x f32) Vec4 {
	return Vec4{x, x, x, x}
}

@[inline]
fn sin4(v Vec4) Vec4 {
	return Vec4{math.sinf(v.x), math.sinf(v.y), math.sinf(v.z), math.sinf(v.w)}
}

@[inline]
fn exp4(v Vec4) Vec4 {
	return Vec4{f32(math.exp(v.x)), f32(math.exp(v.y)), f32(math.exp(v.z)), f32(math.exp(v.w))}
}

@[inline]
fn tanh4(v Vec4) Vec4 {
	return (exp4(vec4(2) * v) - vec4(1)) / (exp4(vec4(2) * v) + vec4(1))
}

@[direct_array_access]
fn shader(mut pixels []u32, width u32, height u32, t f32) {
	r := Vec2{width, height}
	for y in 0 .. height {
		for x in 0 .. width {
			mut o := Vec4{}
			fc := Vec2{x, (height - y)}

			mut i := Vec2{}
			p := (fc * vec2(2.0) - r) / vec2(r.y)
			l := vec2(4.0 - 4.0 * math.abs(0.7 - p.dot(p)))
			mut v := p * vec2(l.x)

			for i.y < 8.0 {
				i.y += 1
				v += cos2(v.yx() * vec2(i.y) + i + vec2(t)) / vec2(i.y) + vec2(0.7)
				o += (sin4(v.xyyx()) + vec4(1.0)) * vec4(math.abs(v.x - v.y))
			}
			o = tanh4(vec4(5.0) * exp4(vec4(l.x - 4.0) - vec4(p.y) * Vec4{-1, 1, 2, 0}) / o)

			pixels[y * width + x] = u32(o.x * 255) << 24 | u32(o.y * 255) << 16 | u32(o.z * 255) << 8
		}
	}
}

fn dump_ppm(filepath string, pixels []u32, width int, height int) !int {
	mut f := os.create(filepath) or {
		eprintln('Failed to create file: ${err}')
		return -1
	}
	defer { f.close() }

	f.write_string('P6 ${width} ${height} 255 ')!
	for i in 0 .. width * height {
		pixel := pixels[i]
		f.write([u8((pixel >> 24) & 0xFF), u8((pixel >> 16) & 0xFF), u8((pixel >> 8) & 0xFF)])!
	}

	return 0
}

fn rdtsc() u64 {
	mut a, mut d := u32(0), u32(0)
	asm volatile amd64 {
		rdtsc
		mov a, eax
		mov d, edx
		; =r (a)
		  =r (d)
	}
	return u64(d) << 32 | u64(a)
}

fn cycles_to_seconds(cycles u64) f32 {
	return f32(cycles) / 4000000000
}

fn main() {
	mut pixels := []u32{len: width * height, init: 0}

	count := 10
	mut fi := f32(0)
	mut total_frame_time := u64(0)
	for i := 0; i < count; i++ {
		start := rdtsc()
		shader(mut pixels, width, height, fi)
		end := rdtsc()
		total_frame_time += end - start
		fi += 1
	}

	frame_time := cycles_to_seconds(u64(f64(total_frame_time) / f64(count))) * 1000
	println('Took ${cycles_to_seconds(total_frame_time)} s to render ${count} frames (Avg: ${frame_time}, FPS: ${1000 / frame_time})')

	shader(mut pixels, width, height, 0)
	dump_ppm('image.ppm', pixels, width, height)!
}
