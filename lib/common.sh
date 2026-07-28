#!/usr/bin/env bash

# Load configuration file
load_config() {
    local conf_file="${1:-config/monitor.conf}"
    if [[ -f "$conf_file" ]]; then
        source "$conf_file"
    else
        echo "Error: Configuration file $conf_file not found." >&2
        return 1
    fi
}

# Logging function
log_msg() {
    local level="$1"
    shift
    local msg="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg"
}
