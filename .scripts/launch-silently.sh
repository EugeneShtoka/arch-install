#!/bin/bash

echo "luanch-silently $1 "
hyprctl dispatch exec [workspace $1 silent] $2