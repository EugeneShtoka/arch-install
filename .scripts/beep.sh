function beep() {
    local duration=${1:-0.05}
    local frequency=440

    play -n synth $duration sine $sine &>/dev/null
    ffplay -f lavfi -i "sine=frequency=440:duration=0.08" -autoexit -nodisp 2>/dev/null
}
