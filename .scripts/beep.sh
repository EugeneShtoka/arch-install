function beep() {
    local duration=0.08
    local frequency=440

    ffplay -f lavfi -i "sine=frequency=$frequency:duration=$duration" -autoexit -nodisp 2>/dev/null
}
