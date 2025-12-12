package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:os"
import "core:simd/x86"

WIDTH :: 800
HEIGHT :: 600

vec2 :: [2]f32
vec4 :: [4]f32

tanh4 :: proc(v: vec4) -> vec4 {
	return (linalg.exp(2*v) - 1) / (linalg.exp(2*v) + 1)
}

tanh :: tanh4

Shader :: proc(pixels: []u32, width: int, height: int, t: f32) {
	r := vec2{cast(f32)width, cast(f32)height}

	for y := 0; y < height; y += 1 {
		for x := 0; x < width; x += 1 {
			o: vec4
			FC := vec2{cast(f32)x, cast(f32)(height - y)}

			i : vec2
			p := (FC * 2. - r) / r.y
			l : vec2 = 4. - 4. * abs(.7 - linalg.dot(p, p))
			v := p * l.x

			for ; i.y < 8.; o += (linalg.sin(v.xyyx) + 1.) * abs(v.x - v.y) {
				i.y += 1
				v += linalg.cos(v.yx * i.y + i + t) / i.y + .7;
			}
			o = tanh(5. * linalg.exp(l.x - 4. - p.y * vec4{-1, 1, 2, 0}) / o);

			pixels[y * width + x] = cast(u32)(o.r*255) << 24 | cast(u32)(o.g*255) << 16 | cast(u32)(o.b*255) << 8
		}
	}
}

DumpPPM :: proc(filepath: string, pixels: []u32, width: int, height: int) -> os.Error {
	out, err := os.open(filepath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC)
	if err != nil {
		return err
	}

	fmt.fprintf(out, "P6 %d %d 255 ", width, height)
	for i := 0; i < width * height; i += 1{
		pixel := pixels[i]
		os.write_byte(out, cast(u8)((pixel >> 24) & 0xFF))
		os.write_byte(out, cast(u8)((pixel >> 16) & 0xFF))
		os.write_byte(out, cast(u8)((pixel >> 8) & 0xFF))
	}

	os.close(out)
	return nil
}

CyclesToSeconds :: proc(cycles: u64) -> f32 {
	return cast(f32)cycles / 4000000000;
}

main :: proc() {
	pixels := make([]u32, WIDTH*HEIGHT)

	fi: f32
	count := 10
	totalFrameTime: u64
	for i := 0; i < count; i += 1{
		start := x86._rdtsc()
		Shader(pixels, WIDTH, HEIGHT, fi)
		end := x86._rdtsc()
		totalFrameTime += end - start
		fi += 1
	}

	frameTime := CyclesToSeconds(cast(u64)(cast(f32)totalFrameTime/cast(f32)count))*1000
	fmt.printf("Took %f s to render %d frames (Avg: %f, FPS: %g)\n", CyclesToSeconds(totalFrameTime), count, frameTime, 1000 / frameTime)

	Shader(pixels, WIDTH, HEIGHT, 0)
	if err := DumpPPM("image.ppm", pixels, WIDTH, HEIGHT); err != nil {
		fmt.eprintln(err)
	}
}
