#!/bin/sh
wallpaper="$1"
output="$2"
rollover=110
region_width_percent=10
region_height_percent=5

missing=()
if ! command -v magick &>/dev/null; then
    missing+=("ImageMagick")
fi

if ! command -v bc &>/dev/null; then
    missing+=("bc")
fi

if [ ${#missing[@]} -ne 0 ]; then
    echo "following tools are not installed:"
    for cmd in "${missing[@]}"; do
        echo " - $cmd"
    done
    exit 1
fi


image_width=$(identify -format "%w" "$wallpaper")
image_height=$(identify -format "%h" "$wallpaper")
image_center=$((image_width / 2))
region_width=$((image_width * region_width_percent / 100))
region_height=$((image_height * region_height_percent / 100))

regions=(
  "left 0x0"
  "center $((image_center - region_width / 2))x0"
  "right $((image_width - region_width))x0"
)

echo "" > $output

i=1

for entry in "${regions[@]}"; do
  name=$(echo "$entry" | awk '{print $1}')
  coords=$(echo "$entry" | awk '{print $2}')

  hexcode=$(magick "$wallpaper" -crop "${region_width}x${region_height}+$coords" -resize 1x1\! -depth 8 -colorspace RGB txt:- | grep -om1 '#[0-9A-Fa-f]\{6\}')

  r=$((16#${hexcode:1:2}))
  g=$((16#${hexcode:3:2}))
  b=$((16#${hexcode:5:2}))

  brightness=$(awk -v r=$r -v g=$g -v b=$b 'BEGIN {
    printf "%.2f", (0.299*r + 0.587*g + 0.114*b)
  }')

  if (( $(echo "$brightness < $rollover" | bc -l) )); then
    text_color="white"
    condition="<"
  else
    text_color="black"
    condition=">"
  fi

  #echo "[d] $name: $text_color [$brightness]"

  declare "bcolor$i=$brightness"
  (( i++ ))
  echo "@define-color color-$name $text_color;" >> "$output"
done

echo "[d] l: $bcolor1 | c: $bcolor2 | r: $bcolor3"
echo "[w] $output"
