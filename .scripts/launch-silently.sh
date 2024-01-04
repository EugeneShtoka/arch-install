#!/bin/bash

echo "luanch-silently $"
hyprctl dispatch exec [workspace $1 silent] $2