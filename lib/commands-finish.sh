#!/usr/bin/env bash

cmd_finish() {
    ## Finish the current ticket in Jira
    ## parameters are optional, as they can be prompted
    ## finish {comment}

    require_command gh

    verify_config_or_die

    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Check if the branch is valid
    if ! provider_validate_branch_name "$branch"; then
        print_status_message error "You must be on a branch named with the ticket format."
        exit 1
    fi

    # Get the issue key from the branch name
    issue=$(provider_get_issue_key_from_branch_name "$branch")

    # Transition the ticket to In Review and add a comment
    provider_transition_workitem "$issue" "Done"

    # close pr
    gh pr merge "$branch" --squash -d
    if [ $? -ne 0 ]; then
        print_status_message error "Failed to merge PR for issue $issue."
        exit 1
    fi

    # Checkout the base branch and pull the latest changes
    git checkout "$(get_config_value base_branch)"
    git pull

    print_status_message success "Ticket $issue marked as done, branch closed."
}