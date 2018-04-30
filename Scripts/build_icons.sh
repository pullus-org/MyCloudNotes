#!/bin/bash

function build_icon {
	size=$1
	variant=$2
	rsvg-convert -w ${size} -h ${size} -f png -o "icon-${variant}.png" MyCloudNotes.svg 
}

build_icon   16 16
build_icon   32 16@2x
build_icon   32 32
build_icon   64 32@2x
build_icon  128 128
build_icon  256 128@2x
build_icon  256 256
build_icon  512 256@2x
build_icon  512 512
build_icon 1024 512@2x
