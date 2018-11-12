#!/bin/bash
# gitprompt.sh by Christer Enfors -- http://github.com/enfors/gitprompt

GITPROMPT_VERSION="1.1.0"

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"
WHITE=$RESET
BLACK=$RESET

GIT_EXIT_STATUS_COLOR=$RED
GIT_TIME_COLOR=$RESET
GIT_BRACKET_COLOR=$BLUE
GIT_AT_COLOR=$RESET
GIT_USERNAME_COLOR=$GREEN
GIT_HOSTNAME_COLOR=$GREEN
GIT_HOSTALIAS_COLOR=$RESET
GIT_COLON_COLOR=$RESET
GIT_PWD_COLOR=$YELLOW

GIT_ADDED_COLOR=$YELLOW
GIT_UNTRACKED_COLOR=$CYAN
GIT_MODIFIED_COLOR=$BLUE
GIT_DELETED_COLOR=$RED
GIT_RENAMED_COLOR=$MAGENTA
GIT_COPIED_COLOR=$MAGENTA
GIT_UNMERGED_COLOR=$MAGENTA

# Display the exit status of the previous command, if non-zero.
function ExitStatus
{
    gs_exitstatus=$?

    if [ $gs_exitstatus -ne 0 ]; then
	echo -en "${GIT_EXIT_STATUS}Exit status: $gs_exitstatus $RESET"
    fi
}

function SetHostAlias
{
    if [ -n "$HOSTALIAS" ]; then
	hostalias="$GIT_BRACKET_COLOR[$RESET$HOSTALIAS$GIT_BRACKET_COLOR]$RESET"
    else
	hostalias=""
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
		echo -en "${GIT_ADDED_COLOR}Added${RESET}"
	    fi
	elif [[ $line == \?\?* ]]; then
	    if [ -z "$untracked" ]; then
		untracked=1
		MaybeEchoComma
		echo -en "${GIT_UNTRACKED_COLOR}Untracked${RESET}"
	    fi
	elif [[ $line == M* ]]; then
	    if [ -z "$modified" ]; then
		modified=1
		MaybeEchoComma
		echo -en "${GIT_MODIFIED_COLOR}Modified${RESET}"
	    fi
	elif [[ $line == D* ]]; then
	    if [ -z "$deleted" ]; then
		deleted=1
		MaybeEchoComma
		echo -en "${GIT_DELETED_COLOR}Deleted${RESET}"
	    fi
	elif [[ $line == R* ]]; then
	    if [ -z "$renamed" ]; then
		renamed=1
		MaybeEchoComma
		echo -en "${GIT_RENAMED_COLOR}Renamed${RESET}"
	    fi
	elif [[ $line == C* ]]; then
	    if [ -z "$copied" ]; then
		copied=1
		echo -en ", ${GIT_COPIED_COLOR}Copied${RESET}"
	    fi
	elif [[ $line == U* ]]; then
	    if [ -z "$unmerged" ]; then
		copied=1
		MaybeEchoComma
		echo -en "${GIT_UNMERGED_COLOR}Updated-but-unmerged${RESET}"
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
		echo -e "$GIT_BRACKET_COLOR[$RESET$gs_branch$GIT_BRACKET_COLOR]$RESET: ${GREEN}Up-to-date${RESET}"
	    else
		echo -e "$GIT_BRACKET_COLOR[$RESET$gs_branch$GIT_BRACKET_COLOR]$RESET: $gs_gitstatus"
	    fi
	fi
    fi
}

SetHostAlias

export PS1="\$(ExitStatus)$GIT_BRACKET_COLOR[$RESET\$(date +%H:%M)$GIT_BRACKET_COLOR]$RESET $GIT_USERNAME_COLOR\u$GIT_AT_COLOR @ $GIT_HOSTNAME_COLOR\h$RESET$hostalias: $GIT_PWD_COLOR\w$RESET \$(GitStatus)\n\$ "

