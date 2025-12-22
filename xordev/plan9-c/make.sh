#!/bin/sh

set -e

. go14-env
go tool 6g main.go
go tool 6c -w -I $HOME/go14/src/runtime -I $HOME/go14/src/cmd/ld shader.c
go tool pack c main.a main.6 shader.6
go tool 6l -o main main.a
