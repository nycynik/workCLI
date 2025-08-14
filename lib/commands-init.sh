#!/usr/bin/env bash

## Setup Jira command line
setup_jira() {

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


cmd_init() {
    # Call the setup function
    setup_jira
    setup_github
}