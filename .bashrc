# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

set -o vi
stty -ixon

alias fd=fdfind
export EDITOR='nvim -u NONE'
export VISUAL='nvim -u NONE'

# deep node
alias dn='node ~/scripts/deep_node_log.js'


alias tmuxmobile='tmux source-file ~/.tmux.mobile.conf'
alias get_idf='. $HOME/esp/esp-idf/export.sh'

alias nv="NVIM_APPNAME='nvim-next' nvim"
alias wezterm='flatpak run org.wezfurlong.wezterm'


source ~/scripts/sync_project/sync_project.sh
source ~/scripts/histogram.sh
source ~/scripts/remrep.sh
source ~/scripts/diffwatch.sh
source ~/scripts/jsonstr/jsonstr.sh
source ~/.aliases

# set Tallinn as default time zone
export TZ=Europe/Tallinn

function remsh() {
    local MOUNT_INFO=$(findmnt $(df . | awk 'NR==2{print $6}') | awk 'NR==2{print $0}')
    local MOUNT_FSTYPE=$(echo $MOUNT_INFO | awk '{print $3}')

    if [ "$MOUNT_FSTYPE" != "fuse.sshfs" ]
    then
        echo "ERROR: Directory not mounted with fuse.sshfs. FSTYPE = $MOUNT_FSTYPE"
        return 1
    fi

    local MOUNT_TARGET=$(echo $MOUNT_INFO | awk '{print $1}')
    local MOUNT_SOURCE=$(echo $MOUNT_INFO | awk '{print $2}')

    # echo "mount target = $MOUNT_TARGET"
    # echo "mount source = $MOUNT_SOURCE"

    local MOUNT_SSH=$(echo $MOUNT_SOURCE | awk -F':' '{print $1}')
    local MOUNT_DIR=$(echo $MOUNT_SOURCE | awk -F':' '{print $2}')
    # echo "ssh = $MOUNT_SSH"
    # echo "ssh = $MOUNT_DIR"

    local CURRENT_DIR=$PWD
    # echo "current dir = $CURRENT_DIR"

    local RELATIVE_DIR=$(realpath --relative-to="$MOUNT_TARGET" "$CURRENT_DIR")
    # echo "relative dir = |$RELATIVE_DIR|"

    if [ "$RELATIVE_DIR" = "." ]
    then
        if [ $# -eq 0 ]
        then
            # echo "no arguments and root dir"
            echo "##########################################"
            echo "# ssh to $MOUNT_SOURCE [home]"
            echo "##########################################"
            ssh $MOUNT_SSH
            echo "##########################################"
            echo "# return to $MOUNT_TARGET"
            echo "##########################################"
            return 0;
        else
            # echo "$# arguments and root dir"
            echo "##########################################"
            echo "# remote: $MOUNT_SOURCE [home]"
            echo "# $@"
            echo "##########################################"
            ssh $MOUNT_SSH $@
            return 0;
        fi
    else
        local MOUNT_PATH="$MOUNT_DIR/$RELATIVE_DIR"
        if [ $# -eq 0 ]
        then
            # echo "no arguments and NOT root dir"
            echo "##########################################"
            echo "# ssh to $MOUNT_SOURCE/$RELATIVE_DIR "
            echo "##########################################"
            ssh -t $MOUNT_SSH "cd $RELATIVE_DIR; exec \$SHELL -l"
            echo "##########################################"
            echo "# return to $MOUNT_TARGET"
            echo "##########################################"
            return 0;
        else
            # echo "$# arguments and NOT root dir"
            echo "##########################################"
            echo "# remote: $MOUNT_SOURCE/$RELATIVE_DIR"
            echo "# $@"
            echo "##########################################"
            ssh $MOUNT_SSH "cd $RELATIVE_DIR; exec \$SHELL -c \"$@\""
            return 0;
        fi
    fi
}


# pnpm
export PNPM_HOME="/home/alari/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Load Angular CLI autocompletion.
source <(ng completion script)

PATH="/home/alari/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/alari/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/alari/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/alari/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/alari/perl5"; export PERL_MM_OPT;

. "$HOME/.cargo/env"

# THIS MESSES UP NVIM REAL BAD!
# TODO: make it toggleable?
# # save last stdout to LAST_STDOUT
# LAST_STDOUT="$(mktemp -u)"
# exec > >(tee $LAST_STDOUT)

# # save last stderr to LAST_STDERR
# LAST_STDERR="$(mktemp -u)"
# exec 2> >(tee $LAST_STDERR >&2)

# function clip() {
#     xclip -selection clipboard < "$LAST_STDOUT"
# }

# function cliperr() {
#     xclip -selection clipboard < "$LAST_STDERR"
# }

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=/home/alari/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/home/alari/tools/latexdiff
export PATH=$PATH:/home/alari/tools
export SPHINXBUILD=/home/alari/bin/sphinx-build
# export ZEPHYR_BASE=/home/alari/zephyrproject
export ZEPHYR_BASE=/home/alari/ncs_v2.5.2


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
