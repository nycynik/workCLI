#!/usr/bin/env bash

cmd_done() {
    ## Finish the current ticket in Jira
    ## parameters are optional, as they can be prompted
    ## done {comment}

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
    provider_add_comment "$issue" "$comment"
    provider_transition_workitem "$issue" "In Review"

    gh pr create --base "$(get_config_values base_branch)" --head "$branch" --title "$issue: $comment" --body "Closes $issue"

    # open pr
    gh pr view --web

    print_status_message success "Ticket $issue marked as done."
}