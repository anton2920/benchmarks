#!/bin/sh

c3c compile -O5 --x86cpu=native --x86vec=avx -z '-static' main.c3 >/dev/null
