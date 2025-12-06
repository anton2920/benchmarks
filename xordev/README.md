# xordev

This benchmark consists of rendering a [cool-looking shader](https://x.com/XorDev/status/1894123951401378051) as fast as possible. The goal is to see how easy it is to leverage modern CPU capabilities (i.e. AVX2, multithreading, etc.) using a particular language.

## Results

- CPU: Intel® Core™ i7 6700K @ 4 GHz
- RAM: 32GiB
- OS: FreeBSD 14.3

|               | Performance   | Toolchain deps | Executable deps | How much to implement?                          | Toolchain size | | How much I like this language? / 10 | Perspective / 5 | Recommendation / 5 |
|---------------|---------------|----------------|-----------------|-------------------------------------------------|----------------|-|-------------------------------------|-----------------|--------------------|
| C             |               |                |                 |                                                 |                | |                                     |                 |                    |
| Plan 9 C      |               |                |                 |                                                 |                | |                                     |                 |                    |
| C++ (clang)   | 5.7/7.2 FPS   | 7              | ±5 dlls         | 2 types with 17 operators and 6 functions       | ±469 MiB       | | 2.f                                 | ✗✗              | ✗✗✗✗✗              |
| Go (w/no CGO) | 1.12/1.13 FPS | 0              | 0               | 3 types with 14 methods and 5 functions         | 241 MiB        | | 7?                                  | ✓✓✓             | ✓✓✓✓✓              |
| Intel® ISPC   | 53 FPS        | 20             | ±1 dll          | 5 functions                                     | 2 GiB          | | 8?                                  | ✓✓✓✓✓           | ✓✓✓✓               |
| Odin          | 5.2 FPS       | 13             | 2 dlls          | 4 functions                                     | 2 GiB          | | 5?                                  | ✓✓✓             | ✓✓                 |
| Alef          |               |                |                 |                                                 |                | |                                     |                 |                    |
| Jai?          |               |                |                 |                                                 |                | |                                     |                 |                    |
|               |               |                |                 |                                                 |                | |                                     |                 |                    |
| Rust          | 5.7/7 FPS     | 10             | ±4 dlls         | 2 types with 19 trait methods and 5 functions   | 1 GiB          | | 1.f                                 | ?               | ?                  |
| Zig           |               |                |                 |                                                 |                | |                                     |                 |                    |
| V             |               |                |                 |                                                 |                | |                                     |                 |                    |
| Mojo          |               |                |                 |                                                 |                | |                                     |                 |                    |
| Haskell       |               |                |                 |                                                 |                | |                                     |                 |                    |
| Carbon        |               |                |                 |                                                 |                | |                                     |                 |                    |
|               |               |                |                 |                                                 |                | |                                     |                 |                    |
| Java          |               |                |                 |                                                 |                | |                                     |                 |                    |
| C#            |               |                |                 |                                                 |                | |                                     |                 |                    |
| Kotlin        |               |                |                 |                                                 |                | |                                     |                 |                    |
| Swift         |               |                |                 |                                                 |                | |                                     |                 |                    |
| JS (Node)     |               |                |                 |                                                 |                | |                                     |                 |                    |
| JS (Bun)      |               |                |                 |                                                 |                | |                                     |                 |                    |
| JS (Deno)     |               |                |                 |                                                 |                | |                                     |                 |                    |
|               |               |                |                 |                                                 |                | |                                     |                 |                    |
| C3            |               |                |                 |                                                 |                | |                                     |                 |                    |
| Hare          |               |                |                 |                                                 |                | |                                     |                 |                    |



