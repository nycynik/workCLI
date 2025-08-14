#!/usr/bin/env bash

# Shared utilities

# Define color variables
SUCCESS_COLOR='\033[0;32m'
ERROR_COLOR='\033[0;31m'
WARNING_COLOR='\033[0;33m'
INFO_COLOR='\033[0;34m'
NC='\033[0m' # No Color

cmd_help() {
    echo -e "${INFO_COLOR}Usage: workcli <command> [options]${NC}"
    echo -e "${INFO_COLOR}Commands:${NC}"
    echo -e "  init    Initialize the workspace"
    echo -e "  create  Create a new ticket"
    echo -e "  help    Show this help message"
    echo -e "  --version Show version information"
}

cmd_version() {
    if [[ -f "$PROJECT_ROOT/.mytool-version" ]]; then
        cat "$PROJECT_ROOT/.mytool-version"
    else
        echo "0.1.0"
    fi
}


# define a function to print messages with icons and colors
print_status_message() {
    local type="$1"
    local message="$2"
    case "$type" in
        success)
            echo -e "${SUCCESS_COLOR}✔${NC} ${message}"
            ;;
        error)
            echo -e "${ERROR_COLOR}✖${NC} ${message}${NC}"
            ;;
        warning)
            echo -e "${WARNING_COLOR}⚠${NC} ${message}${NC}"
            ;;
        info)
            echo -e "${INFO_COLOR}•${NC} ${message}${NC}"
            ;;
        *)
            echo -e "${NC}${message}${NC}"
            ;;
    esac
}

log() {
    echo "[workcli] $*"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        print_status_message warning "Error: Required command '$1' not found" >&2
        exit 1
    }
}