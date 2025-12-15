#!/bin/sh

ldc2 -O5 --static --of=main main.d -L -lelf
