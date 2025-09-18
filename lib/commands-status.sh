#!/usr/bin/env bash

cmd_status() {
    ## Check the status of the current checked out branch
    ## since the branch name is a jira ticket.

    verify_config_or_die

    if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
        print_status_message error "No commits found on this branch."
        exit 1
    fi

    branch=$(git rev-parse --abbrev-ref HEAD)
    issue_key=$(provider_get_issue_key_from_branch_name "$branch")

    if ! provider_validate_branch_name "$branch"; then
        print_status_message error "You must be on a branch named with the ticket format."
        exit 1
    fi

    if [ -z "$issue_key" ]; then
        print_status_message error "Issue key is required."
        exit 1
    fi

<<<<<<< HEAD
    # Get the status of the issue from Jira, and then add color to the keys
    output=$(acli jira workitem view "$issue_key")
=======
    output=$(provider_get_workitem "$issue_key")
>>>>>>> 0010fe5297c0d6204248ca2124ebe620b054d981

    if [ $? -ne 0 ]; then
        print_status_message error "Failed to retrieve status for issue $issue_key."
        exit 1
    fi

    echo "================================================"
    echo -e "${INFO_COLOR}Issue Key:${NC} ${issue_key}"
    echo "================================================"
    echo -e "$output"
    echo "================================================"

    # display compact list of last 5 commits since creating this branch
    git log dev..HEAD --oneline --no-merges | head -n 5 | awk '{print " - " $1 ": " $2}'

}