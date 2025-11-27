#!/usr/bin/env bash

dir="$HOME/.config/themes/current/"
theme='rofi'

## Run
rofi \
  -show drun \
  -theme ${dir}/${theme}.rasi
