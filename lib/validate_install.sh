#!/usr/bin/env bash

set -euo pipefail

overview_instance_running() {
    qs --path "$HOME/.config/quickshell/overview" list --all 2>/dev/null | grep -q '^Instance '
}

start_overview_instance() {
    local attempt

    for attempt in {1..5}; do
        if overview_instance_running; then
            qs kill -p "$HOME/.config/quickshell/overview" >/dev/null 2>&1 || true
            sleep 0.5
        fi

        if qs -p "$HOME/.config/quickshell/overview" -d >/dev/null 2>&1; then
            sleep 1.5
            if overview_instance_running; then
                return 0
            fi
        fi

        warning "Quickshell overview start attempt ${attempt}/5 failed; retrying"
        sleep 1
    done

    error "Failed to start Quickshell overview"
}

validate_install() {
    require_command qs

    [[ -d "$HOME/.config/quickshell/overview" ]] || error "Overview directory was not installed"
    [[ -f "$HOME/.config/hypr/autostart.conf" ]] || error "Hyprland autostart.conf is missing"
    [[ -f "$HOME/.config/hypr/bindings.conf" ]] || error "Hyprland bindings.conf is missing"
    [[ -f "$HOME/.config/omarchy/hooks/theme-set.d/45-quickshell.sh" ]] || error "Theme hook was not installed"

    start_overview_instance

    overview_instance_running || error "Overview instance is not running after install"

    success "Validation passed"
}
