#!/bin/zsh

# Volume information (assumes PulseAudio)
get-volume-level() {
    printf $(pactl get-sink-volume $(pactl get-default-sink) | grep -Pom 1 '[0-9]*%' | head -1)
}