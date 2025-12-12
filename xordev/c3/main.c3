import std::io;
import std::math;

const WIDTH = 800;
const HEIGHT = 600;

alias Vec2 = float[<2>];
alias Vec4 = float[<4>];


fn
void
shader(uint *pixels, int width, int height, float t)
{
	Vec2 r = {width, height};
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			Vec4 o;
			Vec2 fc = {x, (float)(height-y)};

			Vec2 i = {0, 0};
			Vec2 p = (fc * 2.0 - r) / r.y;
			Vec2 l = (Vec2)(4.0 - 4.0 * math::abs(0.7 - p.dot(p)));
			Vec2 v = p * l.x;

			for (; i.y < 8.0; o += (math::sin(v.xyyx) + 1.) * math::abs(v.x - v.y)) {
				i.y++;
				v += math::cos(v.yx * i.y + i + t) / i.y + 0.7;
			}
			o = math::tanh(5.0 * math::exp(l.x - 4.0 - p.y * (Vec4){-1, 1, 2, 0}) / o);

			pixels[y * width + x] = (((uint)(o.r*255)) << 24) | (((uint)(o.g*255)) << 16) | (((uint)(o.b*255)) << 8);
		}
	}
}

fn
int
dumpPPM(String filename, uint *pixels, int width, int height)
{
	uint	pixel;
	int	i, j;
	File? out;

	out = std::io::file::open(filename, "wb");
	if (catch err = out) {
		std::io::eprintfn("Failed to open file: %s", err);
		return 1;
	}

	(void)std::io::fprintf(&out, "P6 %d %d 255 ", WIDTH, HEIGHT);
	for (i = 0; i < width * height; i++) {
		pixel = pixels[i];
		(void)out.write_byte((char)((pixel >> 24) & 0xFF));
		(void)out.write_byte((char)((pixel >> 16) & 0xFF));
		(void)out.write_byte((char)((pixel >> 8) & 0xFF));
	}

	return 0;
}

fn
float
cyclesToSeconds(ulong cycles)
{
	return (float)cycles / 4000000000.f;
}

fn
void
main()
{
	ulong start, end, totalFrameTime;
	uint	*pixels;
	int	count;
	float	fi;
	int	i;

	pixels = calloc(WIDTH * HEIGHT * uint.sizeof);
	assert(pixels != null);

	fi = 0;
	count = 10;
	totalFrameTime = 0;
	for (i = 0; i < count; i++) {
		start = $$sysclock();
		shader(pixels, WIDTH, HEIGHT, fi);
		end = $$sysclock();
		totalFrameTime += end - start;
		fi++;
	}

	float	frameTime = cyclesToSeconds((ulong)((double)totalFrameTime / count)) *1000;
	std::io::printf("Took %f s to render %d frames (Avg: %f, FPS: %g)\n", cyclesToSeconds(totalFrameTime), count, frameTime, 1000 / frameTime);

	shader(pixels, WIDTH, HEIGHT, 0.0f);
	dumpPPM("image.ppm", pixels, WIDTH, HEIGHT);
}


