import std.stdio;
import std.math;
import std.math.algebraic;
import core.simd;

alias vec2 = float2;
alias vec4 = float4;

const WIDTH = 800;
const HEIGHT = 600;

pragma(inline)
vec2
Vec2(float x, float y)
{
	vec2 v;

	v.array[0] = x;
	v.array[1] = y;

	return v;
}

pragma(inline)
vec4
Vec4(float x, float y, float z, float w)
{
	vec4 v;

	v.array[0] = x;
	v.array[1] = y;
	v.array[2] = z;
	v.array[3] = w;

	return v;
}

pragma(inline)
float
dot(vec2 a, vec2 b)
{
	return a.array[0]*b.array[0] + a.array[1]*b.array[1];
}

pragma(inline)
vec2
Vec2_yx(vec2 a)
{
	return Vec2(a.array[1], a.array[0]);
}

pragma(inline)
vec4
Vec2_xyyx(vec2 a)
{
	return Vec4(a.array[0], a.array[1], a.array[1], a.array[0]);
}

pragma(inline)
vec4
sin4(vec4 v)
{
	return Vec4(sin(v.array[0]), sin(v.array[1]), sin(v.array[2]), sin(v.array[3]));
}

pragma(inline)
vec4
exp4(vec4 v)
{
	return Vec4(exp(v.array[0]), exp(v.array[1]), exp(v.array[2]), exp(v.array[3]));
}

pragma(inline)
vec4
tanh4(vec4 v)
{
	return (exp4(2*v) - 1) / (exp4(2*v) + 1);
}

pragma(inline)
vec2
cos2(vec2 v)
{
	return Vec2(cos(v.array[0]), cos(v.array[1]));
}

void
Shader(uint[] pixels, int width, int height, float t)
{
	vec2 r = Vec2(width, height);
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			vec4 o = [0, 0, 0, 0];
			vec2 FC = Vec2(x, height - y);

			vec2 i = [0, 0];
			vec2 p = (FC * 2. - r) / r.array[1];
			vec2 l = 4. - 4. * abs(.7 - dot(p, p));
			vec2 v = p * l.array[0];

			for (; i.array[1]++ < 8.; o += (sin4(Vec2_xyyx(v)) + 1.) * abs(v.array[0] - v.array[1]))
				v += cos2(Vec2_yx(v) * i.array[1] + i + t) / i.array[1] + .7;
			vec4 tmp = [-1, 1, 2, 0];
			o = tanh4(5. * exp4(l.array[0] - 4. - p.array[1] * tmp) / o);

			pixels[y * width + x] = ((cast(uint)(o.array[0] * 255)) << 24) | ((cast(uint)(o.array[1] * 255)) << 16) | ((cast(uint)(o.array[2] * 255)) << 8);
		}
	}
}

int
DumpPPM(const char *filename, uint[] pixels, int width, int height)
{
	uint	pixel;
	File _out;
	int	i, j;

	try {
		_out = File("image.ppm", "wb");
	} catch (Exception e) {
		stderr.writeln("Failed to open file: ", e);
		return 1;
	}

	_out.writef("P6 %d %d 255 ", WIDTH, HEIGHT);
	for (i = 0; i < width * height; i++) {
		pixel = pixels[i];
		_out.rawWrite([cast(byte)((pixel >> 24) & 0xFF), cast(byte)((pixel >> 16) & 0xFF), cast(byte)((pixel >> 8) & 0xFF)]);
	}

	_out.close();
	return 0;
}


float
CyclesToSeconds(ulong cycles)
{
	return cast(float)cycles / 4000000000.0f;
}


ulong
rdtsc()
{
	uint high, low;

	asm pure nothrow @trusted @nogc {
		rdtsc;
		mov low, EAX;
		mov high, EDX;
	};

	return cast(ulong)high << 32 | cast(ulong)low;
}

void
main()
{
	ulong start, end, totalFrameTime;
	uint[] pixels;
	int	count;
	float	fi;
	int	i;

	pixels = new uint[WIDTH*HEIGHT];
	assert(pixels != null);

	fi = 0;
	count = 10;
	totalFrameTime = 0;
	for (i = 0; i < count; i++) {
		start = rdtsc();
		Shader(pixels, WIDTH, HEIGHT, fi);
		end = rdtsc();
		totalFrameTime += end - start;
		fi++;
	}

	float	frameTime = CyclesToSeconds(cast(ulong)(cast(double)totalFrameTime / count)) *1000;
	printf("Took %f s to render %d frames (Avg: %f, FPS: %g)\n", CyclesToSeconds(totalFrameTime), count, frameTime, 1000 / frameTime);

	Shader(pixels, WIDTH, HEIGHT, 0.0f);
	DumpPPM("image.ppm", pixels, WIDTH, HEIGHT);
}
