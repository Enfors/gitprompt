# gitprompt -- A Bash prompt which integrates git status.

## Project status

The current version is 1.2.1.

A brief article about it has been published in Hacker Noon:
https://hackernoon.com/why-linux-developers-should-use-gitprompt-8d654e5b87e1

## Installation

To install gitprompt, first `cd` to a suitable directory where you want to
install it. Let's say you want to install it in your home directory, so
just type:

    $ cd
    $ git clone https://www.github.com/enfors/gitprompt
    
To run it, run the following commands in your Bash prompt:

    $ cd gitprompt
    $ . gitprompt.sh

If you want it all the time, add the following to your .profile or .bashrc:

    . ~/gitprompt/gitprompt.sh

Happy Hacking!

## Features

`GitPrompt` has a small but growing number of features

### Showing git status

The main feature of `GitPrompt` is, as the name implies, to display
git status (if files have been modified since the last commit, etc) in
the prompt.

### Showing exit status

If a command failes with a non-zero exit status, this status will be
displayed in the prompt, reducing the risk that the user will miss it.

### Showing the current time in the prompt

Every time you press enter, the current time on the machine will be
displayed in the prompt.

### Showing username and hostname

If you use many different accounts on many different machines, it is
useful to always have the current username and hostname displayed in
the prompt.

### Showing host aliases

If you have a lot of different machines with less-than-helpful
hostnames, which is sometimes the case, then you can set a shell
variable called `HOSTALIAS`, to a more descriptive name, and it too
will be displayed in the prompt.

### Customizing the colors

You can customize the colors used with the `GPConfig` command. If things
go wrong, you can reset the config with `GPReset`.
