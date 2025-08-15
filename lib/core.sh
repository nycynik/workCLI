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
    echo -e "  start   Start working on a ticket"
    echo -e "  finish  Finish working on a ticket"
    echo -e "  create  Create a new ticket"
    echo -e "  status  Show the status of a ticket"
    echo -e "  help    Show this help message"
    echo -e "  --version Show version information"
}

cmd_version() {
    VERSION="0.1.8"
    if [[ $VERBOSE -eq 1 ]]; then
        echo "workcli $VERSION https://github.com/nycynik/workcli"
    else
        echo "workcli $VERSION"
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

get_workcli_config_file() {
    echo "$(git rev-parse --show-toplevel)/.workcli"
}

get_config_values() {
    local key="$1"
    local WORKCLI_PATH

    WORKCLI_PATH="$(get_workcli_config_file)"
    if [ ! -f "$WORKCLI_PATH" ]; then
        die_with_status_code 102
    fi

    grep -E "^\s*$key:\s*" "$WORKCLI_PATH" | sed -E "s/^\s*$key:\s*//" | xargs
}

# Verifications -=--------------------------------
verify_config_or_die() {

    local WORKCLI_PATH

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # check for the config in the root of the git repository
        WORKCLI_PATH="$(git rev-parse --show-toplevel)/.workcli"
        if [ ! -f "$WORKCLI_PATH" ]; then
            die_with_status_code 102
        fi
    else
        die_with_status_code 101
    fi
}

verify_branch_or_die() {
    if [[ ! "$branch" =~ ^[A-Z]+-[0-9]+$ ]]; then
        die_with_status_code 103
    fi
}

check_if_branch_looks_safe_to_fork() {
    # if your on a branch that has a - in it, it might be a ticket, so warn and check if
    # we should proceed.
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$branch" =~ ^[A-Z]+-[0-9]+$ ]]; then
        read -rp "You are on a branch that looks like a Jira ticket ($branch). Do you want to proceed? (y/n) " proceed
        if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
            die_with_status_code 1
        fi
    fi
}

die_with_status_code() {
    local status_code="$1"

    case "$status_code" in
        1)
            message='Aborted by user.'
            ;;
        101)
            message="This folder is not part of a Git repository."
            ;;
        102)
            message="workcli config file not found in root of git repository."
            ;;
        103)
            message="You must be on a branch named like 'PROJECT-123'."
            ;;
        *)
            message="An unknown error occurred."
            ;;
    esac
    print_status_message error "$message"
    exit "$status_code"
}