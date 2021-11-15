#!/bin/bash

meson setup build
ninja -C build

wget -c https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_10MB.mp4

git rev-parse --short HEAD > version.txt
