#!/bin/sh

PROJECT=main

rustc -Ctarget-cpu=native -Copt-level=3 -C target-feature=+crt-static -o $PROJECT $PROJECT.rs
