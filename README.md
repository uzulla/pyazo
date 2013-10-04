pyazo
=====

Gyazo and Gifzo compatible server by perl


install and run
====

```
cpanm --installdeps . 
vi start.sh # if you use Gifzo compatible.
start.sh 
```

Gifzo compatible is optional.
====

If you want use Gifzo compatible, You must install ffmpeg and gifsicle or (ImageMagick( or YoyaMagick)).


start.sh options
====
- export FFMPEG_PATH="/usr/bin/ffmpeg"

FFMpeg path. require by gifzo compatible

- export IM_CONVERT_PATH="/usr/bin/convert"

ImageMagick(or yoya magick or compatible) convert command path. require by gifzo compatible

- export GIFSICLE_PATH="/path/to/gifsicle"

path to gifsicle. require by gifzo compatible

http://www.lcdf.org/gifsicle/

gifsicle is REALLY fast, RECOMMEND

- export FORCE_TMP_GIF="yes"

use GIF temprary file format, fast and compact filesize.(but bit lower quality)

(force yes when use gifsicle)


Sample
====

pyazo is using in Yancha
http://yancha.hachiojipm.org/


rapid setup on instantserver.io (written in japanese)
http://uzulla.hateblo.jp/entry/2013/06/19/202650


see also
====

Gyazo
http://gyazo.com/ja

Gifzo
http://gifzo.net/
