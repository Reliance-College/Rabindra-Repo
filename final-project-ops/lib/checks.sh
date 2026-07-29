#!/usr/bin/env bash

check_disk() {
    local target="$1"
    run_on "$target" "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//'"
}

check_memory() {
    local target="$1"
    run_on "$target" "free | awk '/Mem:/ {printf \"%.0f\", \$3/\$2 * 100}'"
}

check_load() {
    local target="$1"
    run_on "$target" "uptime | awk -F'load average:' '{ print \$2 }' | cut -d, -f1 | xargs"
}

check_reachability() {
    local target="$1"
    ping -c 1 -W 2 "$target" &>/dev/null
}

check_service() {
    local target="$1"
    local service="$2"
    run_on "$target" "systemctl is-active --quiet $service"
}
