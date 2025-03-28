#!/bin/sh

filename="zero.hex"
yes 0 | head -n 65536 > "$filename"