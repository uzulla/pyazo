#!/bin/sh
#export IM_CONVERT_PATH="/Users/zishida/opt/ym/bin/convert"
export IM_CONVERT_PATH="/opt/local/bin/convert"
export FFMPEG_PATH="/opt/local/bin/ffmpeg"
plackup -s Starman -l :5000 app.pl
