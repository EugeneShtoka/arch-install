function beep() {
    local duration=0.08
    local frequency=440

    ffplay -f lavfi -i "sine=$frequency=440:duration=0.08" -autoexit -nodisp 2>/dev/null
}
