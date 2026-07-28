#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library files
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/checks.sh"
source "$SCRIPT_DIR/lib/report.sh"
source "$SCRIPT_DIR/lib/maintenance.sh"

load_config "$SCRIPT_DIR/config/monitor.conf"

show_menu() {
    echo "============================="
    echo "   System Ops Monitoring     "
    echo "============================="
    echo "1. Run Full Health Checks"
    echo "2. Generate System Report"
    echo "3. Run Maintenance Tasks"
    echo "4. Exit"
    echo "============================="
}

main() {
    case "$1" in
        --check)
            check_disk
            check_memory
            ;;
        --report)
            generate_report
            ;;
        --maintenance)
            run_maintenance
            ;;
        *)
            show_menu
            read -p "Select an option [1-4]: " opt
            case $opt in
                1) check_disk; check_memory ;;
                2) generate_report ;;
                3) run_maintenance ;;
                4) exit 0 ;;
                *) echo "Invalid option." ;;
            esac
            ;;
    esac
}

main "$@"
