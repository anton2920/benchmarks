# xordev

This benchmark consists of rendering a [cool-looking shader](https://x.com/XorDev/status/1894123951401378051) as fast as possible. The goal is to see how easy it is to leverage modern CPU capabilities (i.e. AVX2, multithreading, etc.) using a particular language.

Programmed live: [YouTube playlist](https://www.youtube.com/playlist?list=PLzGCcdvEuTxrCvb9EP06IxKamfKnSQQxg).

## Results

- CPU: Intel® Core™ i7 6700K @ 4 GHz
- RAM: 32GiB
- OS: FreeBSD 14.3

|               | How much to implement?                         | Performance | Executable deps | Toolchain deps | Toolchain size | How much I like this language? / 10 | Perspective / 5 | Recommendation / 5 |                                        |
|---------------|------------------------------------------------|-------------|-----------------|----------------|----------------|-------------------------------------|-----------------|--------------------|----------------------------------------|
| Intel® ISPC   | 5 functions                                    | 53/60 FPS   | ±1 dll          | 20             | 2 GiB          | 8                                   | ✓✓✓✓✓           | ✓✓✓✓               |                                        |
| C3            | Zero functions!!!                              | 4.3 FPS     | ±6 dlls         | ?              | 68 MiB         | 6                                   | ✓✓✓✓            | ✓✓✓                |                                        |
| V             | 2 extra methods and 6 functions                | 5.6/7 FPS   | ±6 dlls         | ?              | ?              | 5                                   | ✓✓✓✓            | ✓✓                 |                                        |
| Odin          | 1 function                                     | 5.3 FPS     | 2 dlls          | 13             | 2 GiB          | 5                                   | ✓✓✓✓            | ✓✓                 |                                        |
| D             | 9 functions                                    | 4.14 FPS    | ±6 dlls         | 13             | 2 GiB          | 4                                   | ✓✓              | ✓✓                 |                                        |
| Zig           | 2 function                                     | 4.3 FPS     | 3 dlls          | 12             | 2 GiB          | @as(int, @intCast(2))               | ✓✓              | ✗✗✗                |                                        |
| Swift         | 7 functions                                    | 4.8 FPS     | 22 dlls         | 20             | 2 GiB          | 3                                   | ✗✗✗✗✗           | ✗✗                 | "NOTE: if not on mobile, not on macOS" |
| C++ (clang)   | 2 types with 17 operators, and 6 functions     | 5.7/7.2 FPS | ±5 dlls         | 7              | ±469 MiB       | 2.f                                 | ✗✗              | ✗✗✗✗✗              |                                        |
| Rust          | 2 types with 19 trait methods, and 5 functions | 5.7/7 FPS   | ±4 dlls         | 10             | 1 GiB          | 1.                                  | ?????           | ✗✗                 |                                        |
| Go (w/no CGO) | 3 types with 14 methods, and 5 functions       | 1.12 FPS    | 0               | 0              | 241 MiB        | 7                                   | ✓✓✓             | ✓✓✓✓✓              |                                        |
|               |                                                |             |                 |                |                |                                     |                 |                    |                                        |
| Plan 9 C      | 2 types with 17 operators, and 6 functions     | 0.93 FPS    | 0               | 0              | ?              | 6                                   | ✗✗✗✗✗           | ✗✗✗✗               | NOTE: if not on Plan 9                 |


