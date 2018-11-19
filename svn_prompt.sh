#!/bin/bash
# SvnPrompt.sh by Craig Moore -- http://svnhub.com/craigtmoore/SvnPrompt

VERSION="1.2.1"
RC_FILE=~/.gitpromptrc

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"
WHITE=$RESET
BLACK=$RESET

CLI_EXIT_STATUS_COLOR=$RED
CLI_TIME_COLOR=$RESET
CLI_BRACKET_COLOR=$BLUE
CLI_AT_COLOR=$RESET
CLI_USERNAME_COLOR=$GREEN
CLI_HOSTNAME_COLOR=$GREEN
CLI_HOSTALIAS_COLOR=$RESET
CLI_COLON_COLOR=$RESET
CLI_PWD_COLOR=$YELLOW
CLI_BRANCH_COLOR=$RESET

CLI_ADDED_COLOR=$YELLOW
CLI_UNTRACKED_COLOR=$CYAN
CLI_MODIFIED_COLOR=$BLUE
CLI_DELETED_COLOR=$RED
CLI_RENAMED_COLOR=$MAGENTA
CLI_COPIED_COLOR=$MAGENTA
CLI_UNMERGED_COLOR=$MAGENTA


svn_first=""

#
# INIT FUNCTIONS
#

function Init
{
  EchoGreeting
  
  if [ ! -e $RC_FILE ]; then
    MkConfigFile
    echo "It seems like this is your first time using SvnPrompt."
    echo "SvnPrompt makes the prompt more informative, especially "
    echo "(but not only) if you use svn."
  else
    ReadConfigFile
  fi

  SetEditor
}

function EchoGreeting
{
  echo "[SvnPrompt version $VERSION by Craig Moore enabled. Type 'SPHelp' for help.]"
}

function SetEditor
{
  if [[ -z "$EDITOR" ]]; then
    if [[ -n "$VISUAL" ]]; then
      EDITOR="$VISUAL"
    else
      if [[ $(which nano) ]]; then
        EDITOR="nano"
      else
        EDITOR="vi"
      fi
    fi
  fi
}

function SPHelp
# Displays the help information
{
  cat <<EOF
SvnPrompt help
==============
SvnPrompt is a script which configures your prompt to be a little more
helpful; see https://www.github.com/craigtmoore/GitPrompt for details about
what it does.

SvnPrompt commands
==================
SPConfig     - customize the colors of the prompt
SPReset      - reset the colors to the default
EOF
}

function SPConfig
# Edits the configuration file
{
  ${EDITOR} ${RC_FILE}

  if [[ $? -ne 0 ]]; then
  echo "Editing config file failed; aborting." >&2
  return 1
  fi
  
  ReadConfigFile
  SetPrompt
}

function SPReset
{
  MkConfigFile
  ReadConfigFile
  SetPrompt
}

#
# CONFIG FILE FUNCTIONS
#

function MkConfigFile
{
  if [[ -e "$RC_FILE" ]]; then
    echo -n "Do you want to reset your SvnPrompt config? [y/N]: "
    read answer
    if [[ "$answer" != "y" ]]; then
        echo "Very well - it will be left as it is."
        return 0
    fi  
  fi
  
  cat <<EOF >$RC_FILE
# This is the config file for SvnPrompt.
#
# Color key:
#
# ,-----+------ CLI_BRACKET_COLOR -----------------+-------.
# |     |                                          |       |
# |     |   CLI_AT_COLOR                           |       |
# |     |        |                                 |       |
# |     |        |  CLI_COLON_COLOR                |       |
# |     |        |       |                         |       |
# V     V        v       V                         V       V
# [02:44] craigtmoore @ shodan: ~/devel/shell/SvnPrompt [develop]: Modified
#    ^      ^        ^                 ^               ^
#    |      |        |                 |               |
#    |      |  CLI_HOSTNAME_COLOR   CLI_PWD_COLOR  CLI_BRANCH_COLOR
#    |      |
#    | CLI_USERNAME_COLOR
#    |
# CLI_TIME_COLOR

CLI_EXIT_STATUS_COLOR=\$RED
CLI_TIME_COLOR=\$RESET
CLI_BRACKET_COLOR=\$BLUE
CLI_AT_COLOR=\$RESET
CLI_USERNAME_COLOR=\$GREEN
CLI_HOSTNAME_COLOR=\$GREEN
CLI_HOSTALIAS_COLOR=\$RESET
CLI_COLON_COLOR=\$RESET
CLI_PWD_COLOR=\$YELLOW
CLI_BRANCH_COLOR=\$RESET

CLI_ADDED_COLOR=\$YELLOW
CLI_UNTRACKED_COLOR=\$CYAN
CLI_MODIFIED_COLOR=\$BLUE
CLI_DELETED_COLOR=\$RED
CLI_RENAMED_COLOR=\$MAGENTA
CLI_COPIED_COLOR=\$MAGENTA
CLI_UNMERGED_COLOR=\$MAGENTA
EOF
}

function ReadConfigFile
{
  . $RC_FILE
}

# Display the exit status of the previous command, if non-zero.
function ExitStatus
{
  gs_exitstatus=$?

  if [ $gs_exitstatus -ne 0 ]; then
    echo -en "${CLI_EXIT_STATUS_COLOR}Exit status: $gs_exitstatus $RESET"
  fi
}

function SetHostAlias
{
  if [ -n "$HOSTALIAS" ]; then
    hostalias="$CLI_BRACKET_COLOR[$CLI_HOSTALIAS_COLOR$HOSTALIAS$CLI_BRACKET_COLOR]$RESET"
  else
    hostalias=""
  fi
}

function SetPrompt
{
  SetHostAlias
  export PS1="\n\$(ExitStatus)$CLI_TIME_COLOR\$(date +%H:%M)$RESET $CLI_USERNAME_COLOR\u$CLI_AT_COLOR@$CLI_HOSTNAME_COLOR\h$RESET$hostalias $CLI_PWD_COLOR\w$RESET \$(svnStatus)\n\$ "
}

# This is called before printing each word in a list. The words should be
# comma separated, so it prints a comma unless the word it's supposed to print
# next is the FIRST word.
function MaybeEchoComma
{
  if [[ -n "${svn_first}" ]]; then
    svn_first=""
  else
    echo -n ", "
  fi
}

# Show the svn commit status.
function CommitStatus
{
  local added
  local untracked
  local modified
  local deleted
  local renamed
  local copied
  local unmerged
  local missing
  local out_of_date
  local check_if_up_to_date
  svn status | while read -r line; do
    if [[ ${line} =~ ^A ]]; then
      if [[ -z "${added}" ]]; then
        added=1
        MaybeEchoComma
        echo -en "${CLI_ADDED_COLOR}Added${RESET}"
      fi
    elif [[ ${line} =~ ^\? ]]; then
      if [[ -z "${untracked}" ]]; then
        untracked=1
        MaybeEchoComma
        echo -en "${CLI_UNTRACKED_COLOR}Untracked${RESET}"
      fi
    elif [[ ${line} =~ ^M ]]; then
      if [[ -z "${modified}" ]]; then
        modified=1
        MaybeEchoComma
        echo -en "${CLI_MODIFIED_COLOR}Modified${RESET}"
      fi
    elif [[ ${line} =~ ^D ]]; then
      if [[ -z "${deleted}" ]]; then
        deleted=1
        MaybeEchoComma
        echo -en "${CLI_DELETED_COLOR}Deleted${RESET}"
      fi
    elif [[ ${line} =~ ^R ]]; then
      if [[ -z "${renamed}" ]]; then
        renamed=1
        MaybeEchoComma
        echo -en "${CLI_RENAMED_COLOR}Renamed${RESET}"
      fi
    elif [[ ${line} =~ ^C ]]; then
      if [[ -z "${copied}" ]]; then
        copied=1
        MaybeEchoComma
        echo -en "${CLI_COPIED_COLOR}Copied${RESET}"
      fi
    elif [[ ${line} =~ ^! ]]; then
      if [[ -z "${missing}" ]]; then
        missing=1
        MaybeEchoComma
        echo -en "${CLI_UNMERGED_COLOR}Missing${RESET}"
      fi
    fi
    if [[ -z "${check_if_up_to_date}" ]]; then
      echo "check_if_up_to_date = ${check_if_up_to_date}"
      check_if_up_to_date=1
      svn status -u | sed '$d' | while read -r status_line; do
        if [[ ${status_line} =~ \* ]]; then
          if [[ -z "${out_of_date}" ]]; then
            out_of_date=1
            MaybeEchoComma
            echo -en "${CLI_UNMERGED_COLOR}OutOfDate${RESET}"
          fi
        fi;
      done;
    fi;
  done
  if [[ -z "${check_if_up_to_date}" ]]; then
    check_if_up_to_date=1
    svn status -u | sed '$d' | while read -r status_line; do
      if [[ ${status_line} =~ \* ]]; then
        if [[ -z "${out_of_date}" ]]; then
          out_of_date=1
          MaybeEchoComma
          echo -en "${CLI_UNMERGED_COLOR}OutOfDate${RESET}"
        fi
      fi;
    done;
  fi;

  return 0
}

function svnStatus
{
  svn_first="yes"

  # If we're inside a .svn directory, we can't find the branch / commit status.
  if pwd | grep -q /.svn; then
    return 0
  fi

  if svn info >/dev/null 2>&1; then
    local svn_url=$(svn info | grep ^URL | cut -c6-)
    svn_branch=""
    if [[ ${svn_url} =~ "branches" ]]; then
      svn_branch=${svn_url##*branches/}
      svn_branch=$( echo ${svn_branch} | sed -r 's;(.*)/.*;\1;;' )
    elif [[ ${svn_url} =~ "trunk" ]]; then
      svn_branch="trunk"
    elif [[ ${svn_url} =~ "tags" ]]; then
      svn_branch=${svn_url##*tags/}
      svn_branch="tags/$( echo ${svn_branch} | sed -r 's;(.*)/.*;\1;;' )"
    else
      svn_branch="Unknown"
    fi
    local svn_status=$(CommitStatus)
    if [[ $? -eq 0 ]]; then
      if [[ -z "${svn_status}" ]]; then
        echo -e "$CLI_BRACKET_COLOR[$CLI_BRANCH_COLOR$svn_branch$CLI_BRACKET_COLOR]$RESET: ${GREEN}Up-to-date${RESET}"
      else
        echo -e "$CLI_BRACKET_COLOR[$CLI_BRANCH_COLOR$svn_branch$CLI_BRACKET_COLOR]$RESET: $svn_status"
      fi
    fi
  fi
}

function Main
{
  Init
  SetPrompt
}

Main


