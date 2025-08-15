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


cmd_init() {
    ## Call the setup functions

    require_command acli
    require_command gh

    set_config

    print_status_message info "Initializing workspace..."

    # first check if there is a .workcli file in this root, if not, copy the config.template.yml into that file.
    if [ ! -f ".workcli" ]; then
        cat <<EOF > .workcli
JIRA_PROJECT="PROJECT_KEY"
JIRA_TYPE="Task"
EOF
        print_status_message info "Created .workcli from template."
    fi

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