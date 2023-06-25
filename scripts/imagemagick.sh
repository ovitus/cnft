#!/bin/bash
#
# Use ImageMagick to convert ASCII text to PNG images
#
# c <ascii in> <png out> <bg hex color> <text hex color>
#
# comment out /etc/ImageMagick-6/policy.xml (rename polixy.xmlout)
#
# convert -list font
#
# GIMP RGB Noise 
#   + Correlated noise
#   + Independent RGB
#   + Linear RGB
#   - Guassian distribution

convert --version > /dev/null 2>&1 || exit

cd $(dirname $0) && . tx.env

c () {
convert \
  -annotate +0+128 @$1 \
  -bordercolor "#$3" \
  -fill "#$4" \
  -font "DejaVu-Sans-Mono" \
  -pointsize 128 \
  -size 1000x1000 xc:"#$3" \
  -trim \
  -border 32 \
    $2.png
}

c pikachu.ascii pikachu1 f39412 fff
c pikachu.ascii pikachu2 f39412 746210

c bicycle.ascii bicycle 3a9d04 fff
