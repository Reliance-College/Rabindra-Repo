#!/usr/bin/env bash

perform_backups() {
    local backup_dir="${BACKUP_DIR:-/tmp/backups}"
    local retention="${RETENTION_DAYS:-7}"
    
    log "INFO" "Starting backup process..."
    mkdir -p "$backup_dir"

    local archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$backup_dir/$archive_name" config/ 2>/dev/null
    log "INFO" "Created backup: $backup_dir/$archive_name"

    find "$backup_dir" -type f -name "*.tar.gz" -mtime +"$retention" -exec rm -f {} \;
}

rotate_logs() {
    local log_file="${LOG_FILE:-/tmp/monitor.log}"
    if [[ -f "$log_file" ]]; then
        mv "$log_file" "${log_file}.1"
        touch "$log_file"
        log "INFO" "Log rotation completed."
    fi
}
