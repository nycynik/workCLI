#!/usr/bin/env bash

cmd_status() {
    ## Check the status of the current checked out branch
    ## since the branch name is a jira ticket.

    require_command acli

    verify_config_or_die

    branch=$(git rev-parse --abbrev-ref HEAD)

    if [[ ! "$branch" =~ ^[A-Z]+-[0-9]+$ ]]; then
        print_status_message error "You must be on a branch named like 'PROJECT-123'."
        exit 1
    fi

    issue_key="$branch"

    if [ -z "$issue_key" ]; then
        print_status_message error "Issue key is required."
        exit 1
    fi

    output=$(acli jira workitem get "$issue_key")

    if [ $? -ne 0 ]; then
        print_status_message error "Failed to retrieve status for issue $issue_key."
        exit 1
    fi

    print_status_message info "Status for $issue_key"

    echo "================================================"
    echo -e "${INFO_COLOR}Issue Key:${NC} ${issue_key}"
    echo "================================================"
    echo -e "$output"
    echo "================================================"

    # display compact list of commits
    git log --oneline --no-merges "$branch" | awk '{print " - " $1 ": " $2}'

}