#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
LIB_DIR="$SCRIPT_DIR/lib"
LOCK_FILE="/tmp/monitor.lock"

source "$LIB_DIR/common.sh"
source "$LIB_DIR/checks.sh"
source "$LIB_DIR/report.sh"
source "$LIB_DIR/maintenance.sh"

load_config "$CONFIG_DIR/monitor.conf"

acquire_lock() {
    if ! mkdir "$LOCK_FILE" 2>/dev/null; then
        echo "[ERROR] Another instance of monitor.sh is running." >&2
        exit 1
    fi
    trap 'rm -rf "$LOCK_FILE"' EXIT
}

show_menu() {
    while true; do
        echo "=========================================="
        echo "      OPS MONITORING SYSTEM MENU"
        echo "=========================================="
        echo "1) Run Fleet Status Report"
        echo "2) Run Maintenance & Backups"
        echo "3) Rotate Logs"
        echo "4) Exit"
        echo "=========================================="
        read -p "Select an option [1-4]: " choice
        case $choice in
            1) generate_full_report "$CONFIG_DIR/hosts.conf" ;;
            2) perform_backups ;;
            3) rotate_logs ;;
            4) exit 0 ;;
            *) echo "Invalid option, try again." ;;
        esac
    done
}

acquire_lock

case "$1" in
    --report|-r) generate_full_report "$CONFIG_DIR/hosts.conf" ;;
    --backup|-b) perform_backups ;;
    --rotate|-l) rotate_logs ;;
    --menu|-m|"") show_menu ;;
    *) echo "Usage: $0 [--report|--backup|--rotate|--menu]"; exit 1 ;;
esac
