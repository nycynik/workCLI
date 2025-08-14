#!/usr/bin/env bash

cmd_create() {
    ## Create a new ticket in Jira and begin work on it
    ## parameters are optional, as they can be prompted
    ## create {title} {description}

    require_command acli
    require_command gh

    # acli jira issue create --project "PROJECT_KEY" --type "Task" --summary "$1" --description "$2"
    # gh issue create --title "New ticket title" --body "Detailed description of the new ticket"
    print_status_message success "New ticket created successfully."
}