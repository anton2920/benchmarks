#!/bin/sh

set -e

PROJECT=main

ispc -o shader.o -h shader.h -O3 shader.ispc
cc -O3 -o $PROJECT $PROJECT.c shader.o -static
