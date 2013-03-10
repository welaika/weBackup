#!/bin/bash
# Script to set up a new host backup
# At the moment we have no way to control if ssh-keys are well setted
#+and I don't know if I'll implement this... :s

# Colors for prompt.
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_MAGENTA=$(tput setaf 5)
COLOR_CYAN=$(tput setaf 6)
COLOR_GRAY=$(tput setaf 7)
COLOR_WHITE=$(tput setaf 7 && tput bold)
COLOR_LIGHTRED=$(tput setaf 1 && tput bold)
COLOR_LIGHTGREEN=$(tput setaf 2 && tput bold)
COLOR_LIGHTYELLOW=$(tput setaf 3 && tput bold)
COLOR_LIGHTBLUE=$(tput setaf 4 && tput bold)
COLOR_LIGHTMAGENTA=$(tput setaf 5 && tput bold)
COLOR_LIGHTCYAN=$(tput setaf 6 && tput bold)
COLOR_BOLD=$(tput bold)
COLOR_RESET=$(tput sgr0)

# Colorized feedback functions.
# Helper feedback functions
function info() {
  echo "${COLOR_BOLD}    * ${1}${COLOR_RESET}"
}
function success() {
  echo "${COLOR_BOLD}${COLOR_GREEN}   ** ${1}${COLOR_RESET}"
}
function warning() {
  echo "${COLOR_BOLD}${COLOR_YELLOW}  *** ${1}${COLOR_RESET}"
}
function error() {
  echo "${COLOR_BOLD}${COLOR_RED} **** ${1}${COLOR_RESET}"
}
function question() {
  echo -n "${COLOR_BOLD}${COLOR_BLU}    ? ${1}?${COLOR_RESET} "
}

. configure

question "Hi guy! Do  you want to set up a now host backup? [y] [n]: "
read go

if [[ $go != 'n' ]] && [[ $go != 'y' ]]; then
  error "That was only the first answer...>_> Please, retry and type y for yes or n for no"; exit 1
elif [[ $go == 'n' ]]; then
  info "Mmmm, ok...see you"; exit 0
fi

question "What is the name of the host to add? If it"
question "is a remote site USE its DOMAIN NAME: "
read host

hostconfig=${CONF_DIR}/${host}/host.conf
cp -r $CONF_DIR/template.tpl ${CONF_DIR}/${host}

# getconf ( string array_to_configure, string substitution )
function getconf(){
  sed -i "s/^\[$1\]=$/\[$1\]=$2/" $hostconfig
  return 0
}

question "Is the host a remote host with rdiff-backup installed? [y] [n]: "
read remote

if [[ $remote == 'n' ]]; then
  getconf 0 false
  question "Ok, we have to backup a local directory or a"
  question "remote one mounted locally with sshfs? [local] [sshfs]: "
  read sshfs
  
  if [[ $sshfs == 'local' ]]; then
    getconf 3 false
    
    info "Please, specify the path of the directory to backup."
    info "Start with / and omit the trailing slash."
    waringn "ATTENTION! Please DOUBLE escape SLASHES or"
    warning 'the script will FAIL! e.g.: \\\/mnt\\\/dir: '
    question "Local path: "
    read path
    
    if [ $path == '' ]; then
      error "Path was not optional... Please restart the script now... >_>"
      exit 1
    else   
      getconf 2 $path
    fi
    
  elif [[ $sshfs == 'sshfs' ]]; then
    getconf 3 true
    
    info "Please, specify the path of the directory to backup."
    info "Start with / and omit the trailing slash."
    warnign "ATTENTION! Please DOUBLE escape SLASHES or"
    warning 'the script will FAIL! e.g.: \\\/mnt\\\/dir: '
    question "Local path: "
    read path
    
    if [ $path == '' ]; then
      error "Path was not optional... Please restart the script now... >_>"
      exit 1
    else   
      getconf 2 $path
    fi
    
    question "What is the name of the user you want to use"
    question "to mount to the remote dir using sshfs (your ssh user)? "
    read user
    
    if [ $user == '' ]; then
      error "Username was not optional... Please restart the script now... >_>"
      exit 1
    else
      getconf 1 $user
    fi
    
    info "Do you want (or have) to mount only a"
    info "specific directory of the remote server?"
    info "Please, specify the path of the directory"
    info "Start with / and omit the trailing slash."
    warnign "ATTENTION! Please DOUBLE escape SLASHES or"
    warnign 'the script will FAIL! e.g.: \\\/home\\\/user: '
    question "Remote path: "
    read rpath
    
    if [ $rpath == '' ]; then
      error "Path was not optional... Please restart the script now... >_>"
      exit 1
    else   
      getconf 4 $rpath
    fi
  else #in any of the cases
    error "That was not optional to follow instructions... Please restart the script now... >_>"; exit 1
  fi
  
elif [[ $remote == 'y' ]]; then
  getconf 0 true
  question "What is the name of the user you want to use"
  question "to connect to the remote host? "
  read user
  
  if [ $user == '' ]; then
    error "Username was not an optional... Please restart the script now... >_>"
    exit 1
  else
    getconf 1 $user
  fi
fi

success "All showld be done. Take a look in $hostconfig."
success "Do not forget to ssh-copy-id if needed"
success  "and to configure globbing.conf for your needs."
success "ByeBye"

