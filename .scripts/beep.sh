function beep() {
    local duration=${1:-0.05}
    local sine=${2:-240}

    play -n synth $duration sine $sine &> /dev/null 
}