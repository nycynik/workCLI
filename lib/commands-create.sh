#!/usr/bin/env bash

cmd_create() {
    local title description issue url
    ## Create a new ticket in Jira and begin work on it
    ## parameters are optional, as they can be prompted
    ## create {title} {description}
    require_command gh
    verify_config_or_die

    check_if_branch_looks_safe_to_fork

    # get title either from param or user
    title="${1:-}"
    description="${2:-}"

    if [ -z "$title" ]; then
        read -rp "Enter ticket title: " title
    fi

    if [ -z "$description" ]; then
        read -rp "Enter ticket description: " description
    fi

    read -r issue url <<<"$(provider_create_workitem "$title" "$description")"

    if [ -n "$VERBOSE" ] && [ "$VERBOSE" != "0" ]; then
        echo "Issue Created: $issue"
    fi

    # Create and switch to branch with issue name, and set the upstream
    if ! git rev-parse --verify "$issue" >/dev/null 2>&1; then
        git checkout -b "$issue"
    else
        git checkout "$issue"
    fi
    git branch --set-upstream-to=origin/"$issue"

    # Move the ticket to the next column
<<<<<<< HEAD
    acli jira workitem transition --key "$issue" --status "In Progress" --assignee "@me"
    acli jira workitem assign --key "$issue" --assignee "@me"
=======
    provider_transition_workitem "$issue" "In Progress"
>>>>>>> 0010fe5297c0d6204248ca2124ebe620b054d981

    print_status_message success "New ticket created successfully. $url"
}
