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

# from Sifan's .bashrc


# Sample .bashrc for SuSE Linux
# Copyright (c) SuSE GmbH Nuernberg

# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit


# For some news readers it makes sense to specify the NEWSSERVER variable here
#export NEWSSERVER=your.news.server

# If you want to use a Palm device with Linux, uncomment the two lines below.
# For some (older) Palm Pilots, you might need to set a lower baud rate
# e.g. 57600 or 38400; lowest is 9600 (very slow!)
#
#export PILOTPORT=/dev/pilot
#export PILOTRATE=115200

# do not run if sftp
#[[ ${-#*i}  = ${-} ]] && return

test -s ~/.alias && . ~/.alias || true

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# set prompt to '<host><user> <cmd># '
#PS1='\u@\h \!# '
PS1="\[\033[0;35m\][\u@\[\033[0;31m\]\h\[\033[0;35m\]:\!]#\[\033[0m\] "

# set MANPATH, test for existence of paths
LocalPath=($MANPATH)
for dir in \
        /usr/share/man  /usr/new/X11R4/man /usr/new/X11R5/man  \
        /usr/man /usr/catman /usr/local/man /usr/new/man /opt/sfw/man \
        ;
do
 if [ -d $dir ]; then
        LocalPath=($LocalPath:$dir)
 fi ;
done
MANPATH=$LocalPath; export MANPATH

# set PATH, test for existence of paths
LocalPath=($PATH)
for dir in  \
        /bin /usr/ucb /usr/bin /usr/local/tools ~/bin \
        /usr/local /usr/local/bin /usr/local/etc /usr/local/bin/tools  \
        /usr/ccs/bin /usr/openwin/bin /opt/sfw/bin  /usr/lib/X11 \
        /etc /lib /usr/lib /usr/new /usr/new/pbm \
        ;
do
 if [ -d $dir ]; then
        LocalPath=($LocalPath:$dir)
 fi ;
done
PATH=$LocalPath; export PATH
unset LocalPath

export EDITOR=vi

# Aliases

alias ls='ls -CF' 
alias rpmg='rpm -qa | grep -i '
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias h=history
alias up='cd ..'
alias bye=logout
alias df='/bin/df -k'
alias jobs='jobs -l'
alias lsl='ls -lF | more '
alias ping='ping -a -c 3'
alias dir='ls -l'

alias psg='COLUMNS=250; /bin/ps -aef | grep -i'

alias dirtop='du -sh | sort -hr | head -20'

# Functions

function hg() { COLUMNS=250; history | grep $1 | more; }
function myps() { COLUMNS=250; /usr/bin/ps -edf | grep $LOGNAME | more; }
function hogs() { COLUMNS=250; du -sk $@ | sort -rn | more; }

# Find commands:

# find string in current directory chain; Usage: findstr string
function findstr() { COLUMNS=250; find . -type f -exec grep $1 {} \; -print; }

# find filename in current directory chain; Usage: findname filename
function findname() { COLUMNS=250; find . -name $1 -print; }

# find filename, file with word, file with expression
function findfile() { COLUMNS=250; find . -name $1 -exec ls -ld {} \; ; }
function findword() { COLUMNS=250; find . -type f -exec grep -wil $1 {} \; ; }
function findwords() { COLUMNS=250; find . -type f -exec grep -wi $1 {} /dev/null \; ; }
function findexpr() { COLUMNS=250; find . -type f -exec grep -il $1 {} \; ; }
function findexprs() { COLUMNS=250; find . -type f -exec grep -i $1 {} /dev/null \; ;}

# find big, old, new, dirs
alias findbig='COLUMNS=250; find . -size +100000 -exec ls -lh {} \;'
alias findold='COLUMNS=250; find . -atime +125 -exec ls -l {} \;'
alias findnew='COLUMNS=250; find . \( -ctime -1 -type f \) -exec ls -l {} \;'
alias finddirs='COLUMNS=250; find . -type d -exec ls -ld {} \;'

# ssh and xterm
function sterm() { ssh -fCY $1 /usr/bin/xterm -fa 'Monospace' -fs 14 -sb -rv ;}

alias emb='. /root/.emb'

# Bring in the otis config if the otis tree exists
if [ -f /otis/ops/bin/otis.profile ]; then
	. /otis/ops/bin/otis.profile
fi

###################
# added to test turning off screen saver
###################

#xset s 0 0
#xset s off
#xset -dpms

####################

export display=:0.0
xhost + &> /dev/null

#/usr/bin/synergys -c /etc/synergy.conf

# for MCP2221 usb to i2c etc board
#export BLINKA_MCP2221='1'


cd ~/

