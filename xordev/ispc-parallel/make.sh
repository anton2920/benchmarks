#!/bin/sh

set -e

PROJECT=main

ispc -o shader.o -h shader.h -O3 shader.ispc
c++ -O3 -o $PROJECT $PROJECT.cpp tasksys.cpp shader.o -static -lpthread
