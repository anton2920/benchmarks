#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <immintrin.h>

#define nil (void*)0ULL

#define WIDTH 800
#define HEIGHT 600

typedef unsigned int uint32;

struct vec4 {
	float x, y, z, w;
	vec4(float x = 0, float y = 0, float z = 0, float w = 0):
		x(x), y(y), z(z), w(w)
	{}
};

struct vec2 {
	float x, y;
	vec2(float x = 0, float y = 0):
		x(x), y(y)
	{}
	vec2 xy() const { return vec2(x, y); }
	vec2 yx() const { return vec2(y, x); }
	vec4 xyyx() const { return vec4(x, y, y, x); }
};

vec2 operator +(const vec2 &a, const vec2 &b) { return vec2(a.x+b.x, a.y+b.y); }
vec2 operator +(const vec2 &a, float s) { return vec2(a.x+s, a.y+s); }

vec2 &operator +=(vec2 &a, const vec2 &b) { a = a + b; return a; }
vec2 &operator +=(vec2 &a, float s) { a = a + s; return a; }

vec2 operator -(const vec2 &a, const vec2 &b) { return vec2(a.x-b.x, a.y-b.y); }

vec2 operator *(const vec2 &a, float s) { return vec2(a.x*s, a.y*s); }
vec2 operator *(const vec2 &a, const vec2 &b) { return vec2(a.x*b.x, a.y*b.y); }
vec2 operator *(float s, const vec2 &a) { return a*s; }

vec2 operator /(const vec2 &a, float s) { return vec2(a.x/s, a.y/s); }

float dot(const vec2 &a, const vec2 &b) { return a.x*b.x + a.y*b.y; }
vec2 abs(const vec2 &a) { return vec2(fabsf(a.x), fabsf(a.y)); }
vec2 cos(const vec2 &a) { return vec2(cosf(a.x), cosf(a.y)); }

vec4 operator +(const vec4 &a, const vec4 &b) { return vec4(a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w); }
vec4 operator +(const vec4 &a, float s) { return vec4(a.x+s, a.y+s, a.z+s, a.w+s); }

vec4 operator -(float s, const vec4 &a) { return vec4(s-a.x, s-a.y, s-a.z, s-a.w); }
vec4 operator -(const vec4 &a, float s) { return vec4(a.x-s, a.y-s, a.z-s, a.w-s); }

vec4 &operator +=(vec4 &a, const vec4 &b) { a = a + b; return a; }

vec4 operator *(const vec4 &a, float s) { return vec4(a.x*s, a.y*s, a.z*s, a.w*s); }
vec4 operator *(float s, const vec4 &a) { return a*s; }

vec4 operator /(const vec4 &a, const vec4 &b) { return vec4(a.x/b.x, a.y/b.y, a.z/b.z, a.w/b.w); }

vec4 sin(const vec4 &a) { return vec4(sinf(a.x), sinf(a.y), sinf(a.z), sinf(a.w)); }
vec4 exp(const vec4 &a) { return vec4(expf(a.x), expf(a.y), expf(a.z), expf(a.w)); }
vec4 tanh(const vec4 &a) { return (exp(2.f*a) - 1.f) / (exp(2.f*a) + 1.f); }


void
Shader(unsigned int pixels[], int width, int height, float t)
{
	const vec2 r = {(float)width, (float)height};
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			vec4 o;
			vec2 FC = {(float)x, (float)(height - y)};

			vec2 i = {0, 0};
			vec2 p = (FC * 2. - r) / r.y;
			vec2 l = 4. - 4. * abs(.7 - dot(p, p));
			vec2 v = p * l.x;

			for (; i.y++ < 8.; o += (sin(v.xyyx()) + 1.) * abs(v.x - v.y))
				v += cos(v.yx() * i.y + i + t) / i.y + .7;
			o = tanh(5. * exp(l.x - 4. - p.y * vec4(-1, 1, 2, 0)) / o);

			pixels[y * width + x] = (((uint32)(o.x * 255)) << 24) | (((uint32)(o.y * 255)) << 16) | (((uint32)(o.z * 255)) << 8);
		}
	}
}


int
DumpPPM(const char *filename, unsigned int *pixels, int width, int height)
{
	unsigned int	pixel;
	FILE * out;
	int	i, j;

	out = fopen(filename, "wb");
	if (out == nil) {
		fprintf(stderr, "Failed to open file: %m\n");
		return 1;
	}

	fprintf(out, "P6 %d %d 255 ", WIDTH, HEIGHT);
	for (i = 0; i < width * height; i++) {
		pixel = pixels[i];
		fputc((pixel >> 24) & 0xFF, out);
		fputc((pixel >> 16) & 0xFF, out);
		fputc((pixel >> 8) & 0xFF, out);
	}

	return 0;
}


float
CyclesToSeconds(__uint64_t cycles)
{
	return (float)cycles / 4000000000.f;
}


int
main()
{
	__uint64_t start, end, totalFrameTime;
	unsigned int	*pixels;
	int	count;
	float	fi;
	int	i;

	pixels = (unsigned int *)calloc(WIDTH * HEIGHT, sizeof(*pixels));
	assert(pixels != nil);

	fi = 0;
	count = 10;
	totalFrameTime = 0;
	for (i = 0; i < count; i++) {
		start = __rdtsc();
		Shader(pixels, WIDTH, HEIGHT, fi);
		end = __rdtsc();
		totalFrameTime += end - start;
		fi++;
	}

	float	frameTime = CyclesToSeconds((double)totalFrameTime / count) *1000;
	printf("Took %f s to render %d frames (Avg: %f, FPS: %g)\n", CyclesToSeconds(totalFrameTime), count, frameTime, 1000 / frameTime);

	Shader(pixels, WIDTH, HEIGHT, 0.0f);
	DumpPPM("image.ppm", pixels, WIDTH, HEIGHT);
}
