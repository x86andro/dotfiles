#!/bin/sh

swaylock -f\
 --hide-keyboard-layout\
 --color 000000\
 --indicator-idle-visible\
 --indicator-radius 50\
 --indicator-thicknes 5\
 --inside-color 000000\
 --inside-clear-color 000000\
 --inside-caps-lock-color 000000\
 --inside-ver-color 000000\
 --inside-wrong-color 000000\
 --line-color 202020\
 --ring-color 000000\
 --ring-clear-color 255255255\
 --ring-ver-color 000000\
 --ring-wrong-color 990000\
 --separator-color 000000\
 --text-color 255255255\
 --text-caps-lock-color 255255255

[ "$1" = "suspend" ] && /sbin/systemctl suspend
