#!/usr/bin/env bash

generate_report() {
    echo "--- System Report ---"
    check_disk
    check_memory
    echo "---------------------"
}
