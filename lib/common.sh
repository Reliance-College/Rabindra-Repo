

#!/usr/bin/env bash

# Load configuration
load_config() {
    local config_file="$1"
    if [[ -f "$config_file" ]]; then
        export $(grep -v '^#' "$config_file" | xargs)
    else
        echo "[ERROR] Config file $config_file not found." >&2
        exit 1
    fi
}

# Logging helper
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" | tee -a "${LOG_FILE:-/tmp/monitor.log}"
}

# Alert webhook notification
notify() {
    local message="$1"
    log "INFO" "Sending notification: $message"
    if [[ -n "$WEBHOOK_URL" ]]; then
        curl -s -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"$message\"}" \
             "$WEBHOOK_URL" > /dev/null || log "WARN" "Failed to send webhook"
    fi
}

# Run command on host (locally or via SSH)
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

# Retry command wrapper
retry() {
    local retries=$1
    shift
    local count=0
    until "$@"; do
        exit_code=$?
        count=$((count + 1))
        if [ $count -lt $retries ]; then
            sleep 2
        else
            return $exit_code
        fi
    done
    return 0
}

# Check TCP port reachability
check_port() {
    local host="$1"
    local port="$2"
    nc -z -w 3 "$host" "$port" &>/dev/null
    return $?
}

# Check HTTP endpoint availability
check_http() {
    local url="$1"
    local status
    status=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 5 "$url")
    if [[ "$status" -ge 200 && "$status" -lt 400 ]]; then
        return 0
    else
        return 1
    fi
}
