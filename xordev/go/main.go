package main

import (
	"fmt"
	"math"
	"os"
	"runtime"
	"unsafe"

	"github.com/anton2920/gofa/cpu"
)

type Float32 float32

func (s Float32) SubVector(v vec4) vec4 {
	return vec4{float32(s) - v.x, float32(s) - v.y, float32(s) - v.z, float32(s) - v.w}
}

type vec2 struct {
	x float32
	y float32
}

func (a vec2) Add(b vec2) vec2 {
	return vec2{a.x + b.x, a.y + b.y}
}

func (a *vec2) AddEq(b vec2) {
	a.x += b.x
	a.y += b.y
}

func (a vec2) AddScalar(s float32) vec2 {
	return vec2{a.x + s, a.y + s}
}

func (a vec2) DivScalar(s float32) vec2 {
	return vec2{a.x / s, a.y / s}
}

func (a vec2) Dot(b vec2) float32 {
	return a.x*b.x + a.y*b.y
}

func (a vec2) Scale(s float32) vec2 {
	return vec2{a.x * s, a.y * s}
}

func (a vec2) Sub(b vec2) vec2 {
	return vec2{a.x - b.x, a.y - b.y}
}

func (v vec2) xyyx() vec4 {
	return vec4{v.x, v.y, v.y, v.x}
}

func (v vec2) yx() vec2 {
	return vec2{v.y, v.x}
}

type vec4 struct {
	x float32
	y float32
	z float32
	w float32
}

func (a *vec4) AddEq(b vec4) {
	a.x += b.x
	a.y += b.y
	a.z += b.z
	a.w += b.w
}

func (a vec4) AddScalar(s float32) vec4 {
	return vec4{a.x + s, a.y + s, a.z + s, a.w + s}
}

func (a vec4) Div(b vec4) vec4 {
	return vec4{a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w}
}

func (a vec4) Scale(s float32) vec4 {
	return vec4{a.x * s, a.y * s, a.z * s, a.w * s}
}

const (
	WIDTH  = 800
	HEIGHT = 600
)

func abs(x float32) float32 {
	px := (*uint32)(unsafe.Pointer(&x))
	*px &= 0x7fffffff
	return *(*float32)(unsafe.Pointer(px))
}

func sin4(v vec4) vec4 {
	return vec4{float32(math.Sin(float64(v.x))), float32(math.Sin(float64(v.y))), float32(math.Sin(float64(v.z))), float32(math.Sin(float64(v.w)))}
}

func exp4(v vec4) vec4 {
	return vec4{float32(math.Exp(float64(v.x))), float32(math.Exp(float64(v.y))), float32(math.Exp(float64(v.z))), float32(math.Exp(float64(v.w)))}
}

func tanh4(v vec4) vec4 {
	return (exp4(v.Scale(2)).AddScalar(-1)).Div(exp4(v.Scale(2)).AddScalar(1))
}

func cos2(v vec2) vec2 {
	return vec2{float32(math.Cos(float64(v.x))), float32(math.Cos(float64(v.y)))}
}

func Shader(pixels []uint32, width int, height int, t float32) {
	r := vec2{float32(width), float32(height)}
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			var o vec4
			FC := vec2{float32(x), float32(height - y)}

			i := vec2{0, 0}
			p := FC.Scale(2).Sub(r).Scale(1 / r.y)
			l := vec2{4 - 4*abs(0.7-p.Dot(p)), 4 - 4*abs(0.7-p.Dot(p))}
			v := p.Scale(l.x)

			for ; i.y < 8; o.AddEq(sin4(v.xyyx()).AddScalar(1).Scale(abs(v.x - v.y))) {
				i.y++
				v.AddEq(cos2(v.yx().Scale(i.y).Add(i).AddScalar(t)).DivScalar(i.y).AddScalar(0.7))
			}
			o = tanh4(exp4(Float32(l.x - 4).SubVector(vec4{-1, 1, 2, 0}.Scale(p.y))).Scale(5).Div(o))

			pixels[y*width+x] = uint32(o.x*255)<<24 | uint32(o.y*255)<<16 | uint32(o.z*255)<<8
		}
	}
}

func DumpPPM(filename string, pixels []uint32, width int, height int) error {
	out, err := os.Create(filename)
	if err != nil {
		return err
	}

	fmt.Fprintf(out, "P6 %d %d 255 ", width, height)
	for i := 0; i < width*height; i++ {
		pixel := pixels[i]
		out.Write([]byte{byte((pixel >> 24) & 0xFF), byte((pixel >> 16) & 0xFF), byte((pixel >> 8) & 0xFF)})
	}

	return out.Close()
}

func CyclesToSeconds(cycles cpu.Cycles) float32 {
	return float32(cycles) / 4000000000
}

func main() {
	pixels := make([]uint32, WIDTH*HEIGHT)

	println(runtime.Version())

	var fi float32
	var totalFrameTime cpu.Cycles
	count := 10
	for i := 0; i < count; i++ {
		start := cpu.ReadPerformanceCounter()
		Shader(pixels, WIDTH, HEIGHT, fi)
		end := cpu.ReadPerformanceCounter()
		totalFrameTime += end - start
	}

	frameTime := CyclesToSeconds(cpu.Cycles(float64(totalFrameTime)/float64(count))) * 1000
	fmt.Printf("Took %f s to render %d frames (Avg: %f, FPS: %g)\n", CyclesToSeconds(totalFrameTime), count, frameTime, 1000/frameTime)

	if err := DumpPPM("image.ppm", pixels, WIDTH, HEIGHT); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to dump pixels into file: %v", err)
		os.Exit(1)
	}
}
