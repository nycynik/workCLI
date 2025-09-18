#!/usr/bin/env bash

cmd_finish() {
    ## Finish the current ticket in Jira
    ## parameters are optional, as they can be prompted
    ## finish {comment}

    require_command acli
    require_command gh

    verify_config_or_die

    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Check if the branch is valid
    verify_branch_or_die

    # Get the issue key from the branch name
    issue="$branch"

    # Transition the ticket to In Review and add a comment
    acli jira workitem transition --key "$issue" --status "Done"

    # close pr
    gh pr merge "$branch" --squash -d
    if [ $? -ne 0 ]; then
        print_status_message error "Failed to merge PR for issue $issue."
        exit 1
    fi

    print_status_message success "Ticket $issue marked as done, branch closed."
}