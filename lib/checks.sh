#!/usr/bin/env bash

check_disk() {
    local usage
    usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "Disk Usage: ${usage}%"
}

check_memory() {
    local free_mem
    free_mem=$(free -m | awk '/Mem:/ {print $4}')
    echo "Free Memory: ${free_mem}MB"
}

check_reachability() {
    local target="$1"
    if ping -c 1 "$target" >/dev/null 2>&1; then
        echo "Host $target is reachable."
    else
        echo "Host $target is UNREACHABLE."
    fi
}
