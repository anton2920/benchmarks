#!/bin/sh

set -e

cc -O3 -c rdtsc.c
swiftc -O -remove-runtime-asserts -import-objc-header rdtsc.h -o main main.swift rdtsc.o
