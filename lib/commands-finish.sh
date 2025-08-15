#!/usr/bin/env bash

cmd_finish() {
    ## Finish the current ticket in Jira
    ## parameters are optional, as they can be prompted
    ## finish {comment}

    require_command acli

    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Check if the branch is valid
    if [[ ! "$branch" =~ ^[A-Z]+-[0-9]+$ ]]; then
        print_status_message error "You must be on a branch named like 'PROJECT-123'."
        exit 1
    fi

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

    # Transition the ticket to Done and add a comment
    acli jira workitem transition "$issue" --to "Done" --comment "$comment"

    pr_url=$(gh pr create --base "$(get_config_value base_branch)" --head "$branch" --title "$issue: $comment" --body "Closes $issue")

    # open pr
    gh pr view "$pr_url"

    print_status_message success "Ticket $issue marked as done."
}