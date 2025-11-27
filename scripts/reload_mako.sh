#!/bin/bash

# Script to reload Mako notification daemon configuration

killall mako

mako &
