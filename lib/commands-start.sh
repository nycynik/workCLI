#!/usr/bin/env bash



cmd_start() {
    ## Start an existing ticket, this is similar to create, but instead of first
    ## making the ticket, it just starts with an existing ticket.
    require_command acli
    require_command gh

    check_if_branch_looks_safe_to_fork

    # get the issue from the command line, if not present exit
    issue="${1:-}"
    if [ -z "$issue" ]; then
        print_status_message error "You must specify a Jira issue key."
        exit 1
    fi

    # check if branch name with Jira ticket pattern exists,
    # if so, it checks out the branch, if not, we create a new one
    if git rev-parse --verify --quiet "$issue"; then
        git checkout "$issue"
    else
        git checkout -b "$issue"
    fi

    # Start the ticket in Jira
    acli jira workitem transition "$issue" --to "In Progress"

    print_status_message success "Ticket $issue is now in progress."
}
