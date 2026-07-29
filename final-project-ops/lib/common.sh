#!/usr/bin/env bash

load_config() {
    local config_file="$1"
    if [[ -f "$config_file" ]]; then
        export $(grep -v '^#' "$config_file" | xargs)
    else
        echo "[ERROR] Config file $config_file not found." >&2
        exit 1
    fi
}

log() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg" | tee -a "${LOG_FILE:-/tmp/monitor.log}"
}

notify() {
    local message="$1"
    log "INFO" "Sending notification: $message"
    if [[ -n "$WEBHOOK_URL" ]]; then
        curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" "$WEBHOOK_URL" > /dev/null || true
    fi
}

run_on() {
    local target="$1"
    shift
    local cmd="$*"
    if [[ "$target" == "127.0.0.1" || "$target" == "localhost" ]]; then
        eval "$cmd"
    else
        ssh -o ConnectTimeout=5 -o BatchMode=yes "$target" "$cmd"
    fi
}

check_http() {
    local url="$1"
    local status
    status=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 5 "$url")
    [[ "$status" -ge 200 && "$status" -lt 400 ]]
}
