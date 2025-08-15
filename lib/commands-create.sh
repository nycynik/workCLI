#!/usr/bin/env bash



cmd_create() {
    local title description issue url jproject jtype
    ## Create a new ticket in Jira and begin work on it
    ## parameters are optional, as they can be prompted
    ## create {title} {description}
    require_command acli
    require_command gh
    verify_config_or_die

    check_if_branch_looks_safe_to_fork

    # get title either from param or user
    title="${1:-}"
    description="${2:-}"
    jproject="$(get_config_values JIRA_PROJECT)"
    jtype="$(get_config_values JIRA_TYPE)"

    if [ -n "$VERBOSE" ] && [ "$VERBOSE" != "0" ]; then
        echo "Creating Jira ticket with the following details:"
        echo "Project: $jproject"
        echo "Type: $jtype"
        echo "Title: $title"
        echo "Description: $description"
    fi

    if [ -z "$title" ]; then
        read -rp "Enter ticket title: " title
    fi

    if [ -z "$description" ]; then
        read -rp "Enter ticket description: " description
    fi

    output=$(acli jira workitem create --project "$jproject" --type "$jtype" --summary "$title" --description "$description" --assignee "@me")

    # Extract the issue key and URL
    issue=$(echo "$output" | grep -oE '[A-Z]+-[0-9]+' | head -n1 | tr -d '[:space:]')
    url=$(echo "$output" | grep -oE 'https?://[^ ]+')

    if [ -n "$VERBOSE" ] && [ "$VERBOSE" != "0" ]; then
        echo "Issue Created: $issue"
    fi

    # Create and switch to branch with issue name, and set the upstream
    if ! git rev-parse --verify "$issue" >/dev/null 2>&1; then
        git checkout -b "$issue"
    else
        git checkout "$issue"
    fi
    git push --set-upstream origin "$issue"

    # Move the ticket to the next column
    acli jira workitem transition --key "$issue" --status "In Progress"

    print_status_message success "New ticket created successfully. $url"
}
