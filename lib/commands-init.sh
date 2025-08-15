#!/usr/bin/env bash

setup_jira() {
    ## Setup Jira command line

    require_command acli

    # check if logged in, if not login
    if ! acli jira auth status &> /dev/null; then
        echo "You are not logged in to Jira. Please log in first."
        acli jira auth login --web
        if [ $? -ne 0 ]; then
            print_status_message error "Login failed. Please check your credentials."
            exit 1
        fi
        print_status_message success "You are logged in to Jira."
    else
        print_status_message info "You are logged in to Jira."
    fi
}

setup_github() {
    ## Setup GitHub command line

    require_command gh

    # check if logged in, if not login
    if ! gh auth status &> /dev/null; then
        print_status_message warning "You are not logged in to GitHub. Please log in first."
        gh auth login --web
        if [ $? -ne 0 ]; then
            print_status_message error "Login failed. Please check your credentials."
            exit 1
        fi
        print_status_message success "You are logged in to GitHub."
    else
        print_status_message info "You are logged in to GitHub."
    fi
}

setup_config() {
    ## Setup configuration file
    local WORKCLI_PATH

    WORKCLI_PATH="$(get_workcli_config_file)"

    if [ ! -f "$WORKCLI_PATH" ]; then
        print_status_message warning "Configuration file not found at $WORKCLI_PATH. Creating a new one."

        # Ask the user for the project from jira.
        read -rp "Enter your Jira project key: " jira_project
        read -rp "Enter your Jira issue type: " jira_type

        touch "$WORKCLI_PATH"
        {
            echo "# Workcli configuration file"
            echo "JIRA_PROJECT: $jira_project"
            echo "JIRA_TYPE: $jira_type"
            echo "GITHUB_REPO: $(gh repo view --json name -q .name)"
            echo "BASE_BRANCH: $(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
        } >> "$WORKCLI_PATH"
    fi
}


cmd_init() {
    ## Call the setup functions

    require_command acli
    require_command gh

    print_status_message info "Initializing workspace..."

    setup_config

    setup_jira
    setup_github

    # if no errors show success
    if [ $? -eq 0 ]; then
        print_status_message success "Workspace initialized successfully."
    else
        print_status_message error "Failed to initialize workspace."
        exit 1
    fi
}