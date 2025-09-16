#!/usr/bin/env bash

# Jira Provider for workcli

# Functions to interact with Jira

provider_create_workitem() {
    require_command acli
    local title="$1"
    local description="$2"
    local jproject jtype output issue url

    jproject="$(get_config_values JIRA_PROJECT)"
    jtype="$(get_config_values JIRA_TYPE)"

    output=$(acli jira workitem create --project "$jproject" --type "$jtype" --summary "$title" --description "$description" --assignee "@me")

    issue=$(echo "$output" | grep -oE '[A-Z]+-[0-9]+' | head -n1 | tr -d '[:space:]')
    url=$(echo "$output" | grep -oE 'https?://[^ ]+')

    echo "$issue $url"
}

provider_transition_workitem() {
    require_command acli
    local issue_key="$1"
    local status="$2"
    acli jira workitem transition --key "$issue_key" --status "$status"
}

provider_get_workitem() {
    require_command acli
    local issue_key="$1"
    acli jira workitem get "$issue_key"
}

provider_add_comment() {
    require_command acli
    local issue_key="$1"
    local comment="$2"
    acli jira workitem comment --key "$issue_key" --body "$comment"
}

provider_validate_branch_name() {
    local branch_name="$1"
    if [[ "$branch_name" =~ ^[A-Z]+-[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

provider_get_issue_key_from_branch_name() {
    local branch_name="$1"
    if provider_validate_branch_name "$branch_name"; then
        echo "$branch_name"
    else
        return 1
    fi
}
