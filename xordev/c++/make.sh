#!/bin/sh

PROJECT=main

c++ -O3 -mavx2 -march=native -o $PROJECT $PROJECT.cpp -static -lm
