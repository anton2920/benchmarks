#![allow(non_camel_case_types)]

#[repr(C)]
struct vec2 {
	x: f32,
	y: f32,
}

/* s - v */
impl std::ops::Sub<vec4> for f32 {
	type Output = vec4;

    fn sub(self, v: vec4) -> vec4 {
        vec4{x: self-v.x, y: self-v.y, z: self-v.z, w: self-v.w}
    }
}

impl vec2 {
	fn yx(&self) -> vec2 {
		vec2{y: self.x, x: self.y}
	}

	fn xyyx(&self) -> vec4 {
		vec4{x: self.x, y: self.y, z: self.y, w: self.x}
	}
}

/* a + b */
impl std::ops::Add<vec2> for vec2 {
	type Output = vec2;

    fn add(self, b: vec2) -> vec2 {
        vec2{x: self.x+b.x, y: self.y+b.y}
    }
}

/* a + b */
impl std::ops::Add<&vec2> for vec2 {
	type Output = vec2;

    fn add(self, b: &vec2) -> vec2 {
        vec2{x: self.x+b.x, y: self.y+b.y}
    }
}

/* a += b */
impl std::ops::AddAssign for vec2 {
    fn add_assign(&mut self, b: Self) {
        *self = Self{x: self.x+b.x, y: self.y+b.y};
    }
}

/* v + s */
impl std::ops::Add<f32> for vec2 {
	type Output = vec2;

    fn add(self, s: f32) -> vec2 {
        vec2{x: self.x+s, y: self.y+s}
    }
}

/* a - b */
impl std::ops::Sub<vec2> for vec2 {
	type Output = vec2;

    fn sub(self, b: vec2) -> vec2 {
        vec2{x: self.x-b.x, y: self.y-b.y}
    }
}

/* a - b */
impl std::ops::Sub<&vec2> for vec2 {
	type Output = vec2;

    fn sub(self, b: &vec2) -> vec2 {
        vec2{x: self.x-b.x, y: self.y-b.y}
    }
}

/* v - s */
impl std::ops::Sub<f32> for &vec2 {
	type Output = vec2;

    fn sub(self, s: f32) -> vec2 {
        vec2{x: self.x-s, y: self.y-s}
    }
}

/* v * s */
impl std::ops::Mul<f32> for vec2 {
	type Output = vec2;

    fn mul(self, s: f32) -> vec2 {
        vec2{x: self.x*s, y: self.y*s}
    }
}

/* v * s */
impl std::ops::Mul<f32> for &vec2 {
	type Output = vec2;

    fn mul(self, s: f32) -> vec2 {
        vec2{x: self.x*s, y: self.y*s}
    }
}

/* v / s */
impl std::ops::Div<f32> for vec2 {
	type Output = vec2;

    fn div(self, s: f32) -> vec2 {
        vec2{x: self.x/s, y: self.y/s}
    }
}

#[repr(C)]
struct vec4 {
	x: f32,
	y: f32,
	w: f32,
	z: f32,
}

/* v + s */
impl std::ops::Add<f32> for vec4 {
	type Output = vec4;

    fn add(self, s: f32) -> vec4 {
        vec4{x: self.x+s, y: self.y+s, z: self.z+s, w: self.w+s}
    }
}

/* a += b */
impl std::ops::AddAssign for vec4 {
    fn add_assign(&mut self, b: Self) {
        *self = Self{x: self.x+b.x, y: self.y+b.y, z: self.z+b.z, w: self.w+b.w};
    }
}

/* v - s */
impl std::ops::Sub<f32> for vec4 {
	type Output = vec4;

    fn sub(self, s: f32) -> vec4 {
        vec4{x: self.x-s, y: self.y-s, z: self.z-s, w: self.w-s}
    }
}

/* v * s */
impl std::ops::Mul<f32> for vec4 {
	type Output = vec4;

    fn mul(self, s: f32) -> vec4 {
        vec4{x: self.x*s, y: self.y*s, z: self.z*s, w: self.w*s}
    }
}

/* v * s */
impl std::ops::Mul<f32> for &vec4 {
	type Output = vec4;

    fn mul(self, s: f32) -> vec4 {
        vec4{x: self.x*s, y: self.y*s, z: self.z*s, w: self.w*s}
    }
}

/* a / b */
impl std::ops::Div<vec4> for vec4 {
	type Output = vec4;

    fn div(self, b: vec4) -> vec4 {
        vec4{x: self.x/b.x, y: self.y/b.y, z: self.z/b.z, w: self.w/b.w}
    }
}

fn cos2(v: &vec2) -> vec2 {
	vec2{x: v.x.cos(), y: v.y.cos()}
}

fn sin4(v: &vec4) -> vec4 {
	vec4{x: v.x.sin(), y: v.y.sin(), z: v.z.sin(), w: v.w.sin()}
}

fn exp4(v: &vec4) -> vec4 {
	vec4{x: v.x.exp(), y: v.y.exp(), z: v.z.exp(), w: v.w.exp()}
}

fn tanh4(v: &vec4) -> vec4 {
	(exp4(&(v*2.)) - 1.) / (exp4(&(v*2.)) + 1.)
}

fn dot(a: &vec2, b: &vec2) -> f32 {
	a.x*b.x + a.y*b.y
}

fn Shader(pixels: &mut [u32], width: i32, height: i32, t: f32) {
	let r = vec2{x: width as f32, y: height as f32};
	for y in 0..height {
		for x in 0..width {
			let mut o = vec4{x: 0., y: 0., z: 0., w: 0.};
			let FC = vec2{x: x as f32, y: (height-y) as f32};

			let mut i = vec2{x: 0., y: 0.};
			let p = (FC * 2. - &r) / r.y;
			let l = vec2{x: 4. - 4. * (0.7 - dot(&p, &p)).abs(), y: 4. - 4. * (0.7 - dot(&p, &p)).abs()};
			let mut v = &p * l.x;

			while i.y < 8. {
				i.y += 1.;
				v += cos2(&(v.yx() * i.y + &i + t)) / i.y + 0.7;
				o += (sin4(&v.xyyx()) + 1.) * (v.x - v.y).abs();
			}
			o = tanh4(&(exp4(&((l.x - 4.) - vec4{x: -1., y: 1., z: 2., w: 0.} * p.y)) * 5. / o));

			pixels[(y * width + x) as usize] = ((((o.x * 255.)) as u32) << 24) | ((((o.y * 255.)) as u32) << 16) | ((((o.z * 255.)) as u32) << 8);
		}
	}
}

fn DumpPPM(filename: &str, pixels: &[u32], width: i32, height: i32) -> Result<(), std::io::Error> {
	let mut out = std::fs::File::create(filename)?;

	use std::io::Write;
	write!(out, "P6 {} {} 255 ", width, height);
	for i in 0..(width*height) {
		let pixel = pixels[i as usize];
		out.write_all(&[((pixel >> 24) & 0xFF) as u8, ((pixel >> 16) & 0xFF) as u8, ((pixel >> 8) & 0xFF) as u8])?;
	}

	Ok(())
}

fn CyclesToSeconds(cycles: u64) -> f32 {
	cycles as f32 / 4000000000.
}

fn main() {
	const WIDTH: i32 = 800;
	const HEIGHT: i32 = 600;
	const count: i32 = 10;

	let mut pixels = [0u32; (WIDTH*HEIGHT) as usize];

	let mut totalFrameTime: u64 = 0;
	let mut fi: f32 = 0.;
	for _ in 0..count {
		let start = unsafe { std::arch::x86_64::_rdtsc() };
		Shader(pixels.as_mut_slice(), WIDTH, HEIGHT, fi);
		let end = unsafe { std::arch::x86_64::_rdtsc() };
		totalFrameTime += end-start;
		fi += 1.;
	}

	let frameTime = CyclesToSeconds((totalFrameTime as f64/ count as f64) as u64) * 1000.;
	println!("Took {} s to render {} frames (Avg: {}, FPS: {})", CyclesToSeconds(totalFrameTime), count, frameTime, 1000./frameTime);

	Shader(pixels.as_mut_slice(), WIDTH, HEIGHT, 0.);
	DumpPPM("image.ppm", &pixels, WIDTH, HEIGHT);
}
