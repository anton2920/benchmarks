#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <immintrin.h>

#include "shader.h"

#define nil (void*)0ULL

#define WIDTH 800
#define HEIGHT 600

using namespace ispc;


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
	count = 100;
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


