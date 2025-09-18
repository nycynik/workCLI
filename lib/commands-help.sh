#!/usr/bin/env bash


cmd_help() {
    ## Show help for workcli
            echo "hi"

    # if no additional arguments are provided, show general help
    if [ $# -eq 0 ]; then
        echo -e "${NC}${INFO_COLOR}workcli - A CLI tool to streamline your workflow with Jira and GitHub${NC}"
        echo -e "\nTo begin: use [init], this will set up a project.\n"
        echo -e "For each ticket, you can either [create] a new ticket and begin working on that, "
        echo -e "\n   or [start] working on an existing ticket.\n${NC}"
        echo -e "Once you have a ticket checked out, you can use the following commands:"
        echo -e "  [done]   Mark a ticket as done"
        echo -e "  [status] Show the status of a ticket"
        echo -e "\nThen once you marked a ticket done, the PR can be reviewed. After \nit's reviewed, you can [finish] the review.\n"
        echo -e "${INFO_COLOR}Usage: workcli <command> [options]${NC}"
        echo -e "${INFO_COLOR}Commands:${NC}"
        echo -e "  create  Create a new ticket"
        echo -e "  done    Mark a ticket as done"
        echo -e "  finish  Finish review of a PR"
        echo -e "  help    Show this help message"
        echo -e "  init    Initialize the workspace"
        echo -e "  start   Start working on a ticket"
        echo -e "  status  Show the status of a ticket"
        echo -e "  --version Show version information"
    else
        # now check for additional help for commands
        case "$1" in
            create)
                echo -e "${INFO_COLOR}create${NC} - Create a new ticket in Jira and begin work on it."
                echo -e "Usage: workcli create {title} {description}"
                echo -e "Parameters are optional, if not supplied they will be prompted."
                ;;
            done)
                echo -e "${INFO_COLOR}done${NC} - Mark the current ticket in Jira as done."
                echo -e "Usage: workcli done {comment}"
                echo -e "Parameters are optional, if not supplied they will be prompted."
                ;;
            finish)
                echo -e "${INFO_COLOR}finish${NC} - Finish the current ticket in Jira after PR review."
                echo -e "Usage: workcli finish {comment}"
                echo -e "Parameters are optional, if not supplied they will be prompted."
                ;;
            init)
                echo -e "${INFO_COLOR}init${NC} - Initialize the workspace for a new project."
                echo -e "Usage: workcli init"
                ;;
            start)
                echo -e "${INFO_COLOR}start${NC} - Start working on an existing ticket in Jira."
                echo -e "Usage: workcli start {issue_key}"
                echo -e "Parameters are optional, as they can be prompted."
                ;;
            status)
                echo -e "${INFO_COLOR}status${NC} - Check the status of the current checked out branch."
                echo -e "Usage: workcli status"
                ;;
            *)
                echo -e "${ERROR_COLOR}Error:${NC} Unknown command '$1'. Use 'workcli help' to see available commands."
                ;;
        esac
    fi

}