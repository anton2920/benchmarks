#include "runtime.h"
#include "arch_amd64.h"
#include "textflag.h"
#include "malloc.h"

/* From <fcntl.h>. */
#define	O_WRONLY	0x0001		/* open for writing only */
#define	O_CREAT		0x0200		/* create if nonexistent */
#define	O_TRUNC		0x0400		/* truncate to zero length */

#define WIDTH  800
#define HEIGHT 600


struct vec2 {
	float32 x;
	float32 y;
};

struct vec4 {
	float32 x;
	float32 y;
	float32 z;
	float32 w;
};

typestr struct vec2 vec2;
typestr struct vec4 vec4;

float32 dot(vec2 a, vec2 b) { return a.x*b.x + a.y*b.y; }
float32
abs(float32 s)
{
	uint32 *is = (uint32*)&s;
	*is &= 0x7FFFFFFF;
	return *(float32*)is;
}

vec2 vec2_add_(vec2 a, vec2 b)    { return (vec2){a.x+b.x, a.y+b.y}; }
vec2 vec2_sub_(vec2 a, vec2 b)    { return (vec2){a.x-b.x, a.y-b.y}; }
vec2 vec2_mul_(vec2 a, vec2 b)    { return (vec2){a.x*b.x, a.y*b.y}; }
vec2 vec2_div_(vec2 a, vec2 b)    { return (vec2){a.x/b.x, a.y/b.y}; }
vec2 vec2_asadd_(vec2 *a, vec2 b) { *a = *a + b; return *a; }
vec2 _fvec2_(float32 s) { return (vec2){s, s}; }

vec2 vec2_yx(vec2 v)   { return (vec2){v.y, v.x}; }
vec4 vec4_xyyx(vec2 v) { return (vec4){v.x, v.y, v.y, v.x}; }

vec4 vec4_add_(vec4 a, vec4 b)    { return (vec4){a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w}; }
vec4 vec4_sub_(vec4 a, vec4 b)    { return (vec4){a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w}; }
vec4 vec4_mul_(vec4 a, vec4 b)    { return (vec4){a.x*b.x, a.y*b.y, a.z*b.z, a.w*b.w}; }
vec4 vec4_div_(vec4 a, vec4 b)    { return (vec4){a.x/b.x, a.y/b.y, a.z/b.z, a.w/b.w}; }
vec4 vec4_asadd_(vec4 *a, vec4 b) { *a = *a + b; return *a; }
vec4 _fvec4_(float32 s) { return (vec4){s, s, s, s}; }

float64 math·Sin(float64);
float64 math·Cos(float64);
float64 math·Exp(float64);

vec2 cos2(vec2 v)  { return (vec2){math·Cos(v.x), math·Cos(v.y)}; }
vec4 sin4(vec4 v)  { return (vec4){math·Sin(v.x), math·Sin(v.y), math·Sin(v.z), math·Sin(v.w)}; }
vec4 exp4(vec4 v)  { return (vec4){math·Exp(v.x), math·Exp(v.y), math·Exp(v.z), math·Exp(v.w)}; }
vec4 tanh4(vec4 v) { return (exp4((vec4)2.f*v) - (vec4)1.f) / (exp4((vec4)2.f*v) + (vec4)1.f); }


static void main();

#pragma textflag NOSPLIT
void
main·main()
{
	void (*fn)() = main;
	runtime·onM(&fn);
}


static
void
Shader(uint32 *pixels, int32 width, int32 height, float32 t)
{
	int32 x, y;

	vec2 r = (vec2){width, height};
	for (y = 0; y < height; ++y) {
		for (x = 0; x < width; ++x) {
			vec4 o = (vec4){0, 0, 0, 0};
			vec2 FC = (vec2){x, height - y};

			/* TODO(anton2920): fix compiler! */
			float32 yy = r.y;
			vec2 i = {0, 0};
			vec2 p = (FC * (vec2)2.f - r) / (vec2)yy;
			vec2 l = (vec2)4.f - (vec2)4.f * (vec2)abs(.7f - dot(p, p));
			vec2 v = p * l;

			while (i.y++ < 8.f) {
				yy = i.y;
				v += cos2(vec2_yx(v) * (vec2)yy + i + (vec2)t) / (vec2)yy + (vec2)0.7f;

				yy = v.y;
				o += (sin4(vec4_xyyx(v)) + (vec4)1.f) * (vec4)abs(v.x - yy);
			}
			yy = p.y;
			o = tanh4(exp4((vec4)(l.x - 4.f) - (vec4)yy * (vec4){-1, 1, 2, 0}) * (vec4)5.f / o);

			pixels[y * width + x] = (((uint32)(o.x * 255)) << 24) | (((uint32)(o.y * 255)) << 16) | (((uint32)(o.z * 255)) << 8);
		}
	}
}


static
int32
strlen(byte *s)
{
	int32 i;

	for (i = 0; s[i]; i++)
		;

	return i;
}


static
int32
DumpPPM(int8 *filename, uint32 *pixels, int32 width, int32 height)
{
	byte buffer[128];
	byte pixelBuffer[3];
	int32 out;
	int32 i;

	out = runtime·open(filename, O_WRONLY|O_CREAT|O_TRUNC, 0644);
	if (out == -1) {
		return -1;
	}

	runtime·snprintf(buffer, sizeof buffer, "P6 %d %d 255 ", width, height);
	runtime·write(out, buffer, strlen(buffer));

	for (i = 0; i < width*height; i++) {
		uint32 pixel = pixels[i];
		pixelBuffer[0] = (pixel >> 24) & 0xFF;
		pixelBuffer[1] = (pixel >> 16) & 0xFF;
		pixelBuffer[2] = (pixel >> 8) & 0xFF;
		runtime·write(out, pixelBuffer, sizeof pixelBuffer);
	}

	runtime·close(out);
	return 0;
}


static
float32
CyclesToSeconds(uint64 cycles)
{
	return (float32)cycles / 4000000000.f;
}


static
void
main()
{
	uint64 start, end, totalFrameTime;
	uint32 *pixels;
	int32	count;
	float32	fi;
	int32	i;

	pixels = runtime·mallocgc(WIDTH*HEIGHT*sizeof(*pixels), nil, FlagNoScan);
	if (pixels == nil) {
		runtime·printf("Failed to allocate memory\n");
		runtime·exit(1);
	}

	fi = 0;
	count = 10;
	totalFrameTime = 0;
	for (i = 0; i < count; i++) {
		start = runtime·cputicks();
		Shader(pixels, WIDTH, HEIGHT, fi);
		end = runtime·cputicks();
		totalFrameTime += end - start;
		fi++;
	}

	float32	frameTime = CyclesToSeconds((float64)totalFrameTime / count) *1000;
	runtime·printf("Took %f s to render %d frames (Avg: %f, FPS: %f)\n", CyclesToSeconds(totalFrameTime), count, frameTime, 1000 / frameTime);

	Shader(pixels, WIDTH, HEIGHT, 0);
	DumpPPM("image.ppm", pixels, WIDTH, HEIGHT);
}


