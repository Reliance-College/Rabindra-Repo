#!/usr/bin/env bash

report_host() {
    local line="$1"
    IFS='|' read -r name target services endpoints <<< "$line"
    
    name=$(echo "$name" | xargs)
    target=$(echo "$target" | xargs)
    services=$(echo "$services" | xargs)
    endpoints=$(echo "$endpoints" | xargs)

    echo "=========================================="
    echo " Report for Host: $name ($target)"
    echo "=========================================="

    if ! check_reachability "$target"; then
        log "CRIT" "Host $name ($target) is UNREACHABLE!"
        notify "🚨 Host $name ($target) is UNREACHABLE!"
        return
    fi
    echo "Status: REACHABLE"

    local disk_usage=$(check_disk "$target")
    echo "Disk Usage: ${disk_usage}%"

    local mem_usage=$(check_memory "$target")
    echo "Memory Usage: ${mem_usage}%"

    local load_avg=$(check_load "$target")
    echo "Load Average: $load_avg"

    if [[ -n "$services" ]]; then
        IFS=',' read -ra SVC_LIST <<< "$services"
        for svc in "${SVC_LIST[@]}"; do
            svc=$(echo "$svc" | xargs)
            if check_service "$target" "$svc"; then
                echo "Service [$svc]: UP"
            else
                echo "Service [$svc]: DOWN"
                log "WARN" "Service $svc on $name is DOWN"
            fi
        done
    fi
    echo ""
}

generate_full_report() {
    local hosts_file="$1"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        report_host "$line"
    done < "$hosts_file"
}
