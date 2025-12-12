#!/bin/sh

v -prod -o main -cflags '-O3 -march=native -mavx2 -static' .
