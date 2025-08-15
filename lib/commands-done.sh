#!/usr/bin/env bash

cmd_done() {
    ## Finish the current ticket in Jira
    ## parameters are optional, as they can be prompted
    ## done {comment}

    require_command acli
    require_command gh

    verify_config_or_die

    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Check if the branch is valid
    verify_branch_or_die

    # Get the issue key from the branch name
    issue="$branch"

    # Get comment either from param or user
    comment="${1:-}"
    if [ -z "$comment" ]; then
        read -rp "Enter comment for ticket completion: " comment
    fi

    # Commit changes to repository if there are any
    if ! git diff --quiet; then
        git commit -m "$issue: $comment"
        git push origin "$branch"
    fi

    # Transition the ticket to In Review and add a comment
    acli jira workitem comment --key "$issue" --body "$comment"
    acli jira workitem transition --key "$issue" --status "In Review"

    gh pr create --base "$(get_config_value base_branch)" --head "$branch" --title "$issue: $comment" --body "Closes $issue"

    # open pr
    gh pr view --web

    print_status_message success "Ticket $issue marked as done."
}