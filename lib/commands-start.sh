#!/usr/bin/env bash



cmd_start() {
    ## Start an existing ticket, this is similar to create, but instead of first
    ## making the ticket, it just starts with an existing ticket.

    require_command gh

    verify_config_or_die

    check_if_branch_looks_safe_to_fork

    # get the issue from the command line, if not present exit
    issue="${1:-}"
    if [ -z "$issue" ]; then
        print_status_message error "You must specify an issue key."
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
<<<<<<< HEAD
    acli jira workitem transition --key "$issue" --status "In Progress"
=======
    provider_transition_workitem "$issue" "In Progress"
>>>>>>> 0010fe5297c0d6204248ca2124ebe620b054d981

    print_status_message success "Ticket $issue is now in progress."
}
