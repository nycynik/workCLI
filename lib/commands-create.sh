#!/usr/bin/env bash



cmd_create() {
    ## Create a new ticket in Jira and begin work on it
    ## parameters are optional, as they can be prompted
    ## create {title} {description}

    require_command acli
    require_command gh

    # get title either from param or user
    title="${1:-}"
    description="${2:-}"
    if [ -z "$title" ]; then
        read -rp "Enter ticket title: " title
    fi

    if [ -z "$description" ]; then
        read -rp "Enter ticket description: " description
    fi

    acli create workitem --project "$(get_config_value project)" --type "$(get_config_value type)" --summary "$title" --description "$description" --assignee "@me"
        # acli jira issue create --project "PROJECT_KEY" --type "Task" --summary "$1" --description "$2"
        # gh issue create --title "New ticket title" --body "Detailed description of the new ticket"
    echo "Creating ticket with title: $title and description: $description"
    print_status_message success "New ticket created successfully."
}