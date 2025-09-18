#!/usr/bin/env bash

# Shared utilities

# Define color variables
SUCCESS_COLOR='\033[0;32m'
ERROR_COLOR='\033[0;31m'
WARNING_COLOR='\033[0;33m'
INFO_COLOR='\033[0;34m'
NC='\033[0m' # No Color


cmd_version() {
    VERSION="0.1.12"
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

load_provider() {
    local provider
    provider=$(get_config_values "PROVIDER" || echo "jira")
    if [ -z "$provider" ]; then
        provider="jira"
    fi

    local provider_file="$LIB_DIR/providers/$provider.sh"
    if [ -f "$provider_file" ]; then
        # shellcheck disable=SC1090
        source "$provider_file"
    else
        print_status_message error "Provider '$provider' not found."
        exit 1
    fi
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
    if ! provider_validate_branch_name "$branch"; then
        die_with_status_code 103
    fi
}

check_if_branch_looks_safe_to_fork() {
    # if your on a branch that has a - in it, it might be a ticket, so warn and check if
    # we should proceed.
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if provider_validate_branch_name "$current_branch"; then
        read -rp "You are on a branch that looks like a ticket ($current_branch). Do you want to proceed? (y/n) " proceed
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
            message="You must be on a branch named with the ticket format."
            ;;
        *)
            message="An unknown error occurred."
            ;;
    esac
    print_status_message error "$message"
    exit "$status_code"
}