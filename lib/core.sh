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
    VERSION="0.1.6"
    echo "$VERSION"
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

get_config_value() {
    local key="$1"
    grep -E "^\s*$key:\s*" .workcli.yaml | sed -E "s/^\s*$key:\s*//"
}

check_if_branch_looks_safe_to_fork() {
    # if your on a branch that has a - in it, it might be a ticket, so warn and check if
    # we should proceed.
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$branch" =~ ^[A-Z]+-[0-9]+$ ]]; then
        read -rp "You are on a branch that looks like a Jira ticket ($branch). Do you want to proceed? (y/n) " proceed
        if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
            print_status_message warning "Aborting."
            exit 1
        fi
    fi
}