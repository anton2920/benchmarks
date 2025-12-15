import Foundation

typealias vec2 = SIMD2<Float>;
typealias vec4 = SIMD4<Float>;

let WIDTH = 800;
let HEIGHT = 600;

@inline(__always)
func dot(_ a: vec2, _ b: vec2) -> Float {
	return a.x*b.x + a.y*b.y;
}

@inline(__always)
func cos2(_ v: vec2) -> vec2 {
	return vec2(cos(v.x), cos(v.y))
}

@inline(__always)
func sin4(_ v: vec4) -> vec4 {
	return vec4(sin(v.x), sin(v.y), sin(v.z), sin(v.w))
}

@inline(__always)
func exp4(_ v: vec4) -> vec4 {
	return vec4(exp(v.x), exp(v.y), exp(v.z), exp(v.w))
}

@inline(__always)
func tanh4(_ v: vec4) -> vec4 {
	return (exp4(2*v) - 1) / (exp4(2*v) + 1)
}

@inline(__always)
func Vec2_yx(_ v: vec2) -> vec2 {
	return vec2(v.y, v.x)
}

@inline(__always)
func Vec2_xyyx(_ v: vec2) -> vec4 {
	return vec4(v.x, v.y, v.y, v.x)
}

func Shader(_ pixels: inout [UInt], _ width: Int, _ height: Int, _ t: Float) {
	let r = vec2(Float(width), Float(height))
	for y in 0 ... height-1 {
		for x in 0 ... width-1 {
			var o: vec4 = vec4(0, 0, 0, 0)
			let FC = vec2(Float(x), Float(height - y))

			var i: vec2 = vec2(0, 0)
			let p = (FC * 2 - r) / r.y
			let l: vec2 = vec2(4 - 4 * abs(0.7 - dot(p, p)), 4 - 4 * abs(0.7 - dot(p, p)))
			var v = p * l.x

			while i.y < 8  {
				i.y += 1
				v += cos2(Vec2_yx(v) * i.y + i + t) / i.y + 0.7
				o += (sin4(Vec2_xyyx(v)) + 1) * abs(v.x - v.y)
			}
			o = tanh4(5.0 * exp4(l.x - 4 - p.y * vec4(-1, 1, 2, 0)) / o)

			/* NOTE(anton2920): compiler cannot do this in one line — this is pathetic! */
			let r: UInt = UInt(o.x*255) << 24
			let g: UInt = UInt(o.y*255) << 16
			let b: UInt = UInt(o.z*255) << 8
			pixels[y * width + x] = r | g | b
		}
	}
}

func DumpPPM(_ filename: String, _ pixels: [UInt], _ width: Int, _ height: Int) {
	var out: FileHandle

	FileManager.default.createFile(atPath: filename, contents:Data("".utf8), attributes: nil)
	let url = URL(fileURLWithPath: filename)
	do {
		out = try FileHandle(forWritingTo: url)
	} catch {
		FileHandle.standardError.write("Failed to open file: \(error)\n".data(using: .utf8)!)
		return
	}

	out.write("P6 \(width) \(height) 255 ".data(using: .utf8)!)
	for i in 0 ... width*height-1 {
		let pixel = pixels[i]
		var data = Data()

		let r = UInt8((pixel >> 24) & 0xFF)
		let g = UInt8((pixel >> 16) & 0xFF)
		let b = UInt8((pixel >> 8) & 0xFF)
		let rgb: [UInt8] = [r, g, b]

		data.append(contentsOf: rgb)
		out.write(data)
	}

	out.closeFile()
}

func CyclesToSeconds(_ cycles: UInt64) -> Float {
	return Float(cycles) / 4000000000
}

var pixels = Array<UInt>(repeating: 0, count: WIDTH*HEIGHT);

let count = 10
var fi: Float = 0
var totalFrameTime: UInt64 = 0

for _ in 0...count-1 {
	let start = rdtsc()
	Shader(&pixels, WIDTH, HEIGHT, fi)
	let end = rdtsc()
	totalFrameTime += end-start
	fi += 1
}

let frameTime = CyclesToSeconds(UInt64(Float(totalFrameTime)/Float(count)))*1000
print("Took \(CyclesToSeconds(totalFrameTime)) s to render \(count) frames (Avg: \(frameTime), FPS: \(1000 / frameTime))")

Shader(&pixels, WIDTH, HEIGHT, 0)
DumpPPM("image.ppm", pixels, WIDTH, HEIGHT)
