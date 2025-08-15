#!/usr/bin/env bash



cmd_create() {
    ## Create a new ticket in Jira and begin work on it
    ## parameters are optional, as they can be prompted
    ## create {title} {description}

    require_command acli
    require_command gh

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

    output=$(acli jira workitem create --project "$(get_config_value project)" --type "$(get_config_value type)" --summary "$title" --description "$description" --assignee "@me")

    # Extract the issue key and URL
    issue=$(echo "$output" | grep -oE '[A-Z]+-[0-9]+')
    url=$(echo "$output" | grep -oE 'https?://[^ ]+')

    # Create and switch to branch with issue name, and set the upstream
    git checkout -b "$issue"
    git push --set-upstream origin "$issue"

    # Move the ticket to the next column
    acli jira workitem transition "$issue" --to "In Progress"

    print_status_message success "New ticket created successfully. $url"
}
