#!/usr/bin/env bash

pbm2ascii() {
    local zero=${1:-0}
    local one=${2:-1}

    local magic width height
    IFS= read -r magic
    IFS=" " read -r width height
    
    local pixels=""
    while IFS= read -r line; do
        pixels+="${line// /}"
    done
    local asciibitmap="$(printf "$pixels" | fold -w $width)"
    printf "SIZE: ${width}x${height}\n"
    printf "$asciibitmap\n" | sed "s/0/$zero/g" | sed "s/1/$one/g"
}

export -f pbm2ascii;
