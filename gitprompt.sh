#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Display the exit status of the previous command, if non-zero.
function ExitStatus
{
    gs_exitstatus=$?

    if [ $gs_exitstatus -ne 0 ]; then
	echo -en "${RED}Exit status: $gs_exitstatus $RESET"
    fi
}

# This is called before printing the each word in a list. The words should be
# comma separated, so it prints a comma unless the word it's supposed to print
# next is the FIRST word.
function MaybeEchoComma
{
    if [ ! -z "$gs_first" ]; then
	gs_first=
    else
	echo -n ", "
    fi
}

# Show the git commit status.
function CommitStatus
{
    unset added
    git status -s --porcelain | while read -r line; do
	if [[ $line == A* ]]; then
	    if [ -z "$added" ]; then
		added=1
		MaybeEchoComma
		echo -en "${YELLOW}Added${RESET}"
	    fi
	elif [[ $line == \?\?* ]]; then
	    if [ -z "$untracked" ]; then
		untracked=1
		MaybeEchoComma
		echo -en "${CYAN}Untracked${RESET}"
	    fi
	elif [[ $line == M* ]]; then
	    if [ -z "$modified" ]; then
		modified=1
		MaybeEchoComma
		echo -en "${BLUE}Modified${RESET}"
	    fi
	elif [[ $line == D* ]]; then
	    if [ -z "$deleted" ]; then
		deleted=1
		MaybeEchoComma
		echo -en "${RED}Deleted${RESET}"
	    fi
	elif [[ $line == R* ]]; then
	    if [ -z "$renamed" ]; then
		renamed=1
		MaybeEchoComma
		echo -en "${MAGENTA}Renamed${RESET}"
	    fi
	elif [[ $line == C* ]]; then
	    if [ -z "$copied" ]; then
		copied=1
		echo -en ", ${MAGENTA}Copied${RESET}"
	    fi
	elif [[ $line == U* ]]; then
	    if [ -z "$unmerged" ]; then
		copied=1
		MaybeEchoComma
		echo -en "${MAGENTA}Updated-but-unmerged${RESET}"
	    fi
	else
	    echo "UNKNOWN STATUS"
	    return 1
        fi
    done

    return 0
}

function GitStatus
{

    gs_first=1

    # If we're inside a .git directory, we can't find the branch / commit status.
    if pwd | grep -q /.git; then
	return 0
    fi

    if git rev-parse --git-dir >/dev/null 2>&1; then
	gs_branch=$(git branch | grep "^* " | cut -c 3-)

	gs_gitstatus=$(CommitStatus)

	if [ $? -eq 0 ]; then
	    if [ -z "$gs_gitstatus" ]; then
		echo -e "$BLUE[$RESET$gs_branch$BLUE]$RESET: ${GREEN}Up-to-date${RESET}"
	    else
		echo -e "$BLUE[$RESET$gs_branch$BLUE]$RESET: $gs_gitstatus"
	    fi
	fi
    fi
}

export PS1="\$(ExitStatus)$BLUE[$RESET\$(date +%H:%M)$BLUE]$RESET $GREEN\u$RESET @ $GREEN\h$RESET: $YELLOW\w$RESET \$(GitStatus)\n\$ "

