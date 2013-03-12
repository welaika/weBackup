#!/bin/bash
# Helper functions for job setup, option parsing, usage

function usage () {
  echo -e "Usage: $0 [OPTIONS] [COMMAND]"
  echo -e "OPTIONS must be specified before COMMAND to be correctly executed."
  echo -e "Settings are defined in the file 'config' in the script folder ( edit before first run )."
  
  echo -e "\nOPTIONS:"
  
  echo -e "  --debug, -d"
  echo -e "    Prevent execution of rdiff-backup command and prints out on stdout the command that would be executed ( useful in testing )."
  
  echo -e "  --mail, -m"
  echo -e "    Send mail with debug informations. Useful with -d to send a report mail with debug, which by default disable mail sending."
  
  echo -e "  --verbose, -v"
  echo -e "    Prints out info on backup status; by default the script run in 'quiet' mode, so that no output is printed on stdout ( this mainly because is unuseful to have stdout in a cronjob ); whit verbose is possible to enable stdout output."
  
  echo -e "  --version"
  echo -e "    Print script version."
    
  echo -e "\nCOMMAND:"
  echo -e "  --backup, -b"
  echo -e "    Execute backup on defined servers/folders."
  
  echo -e "  --restore, -r [ NOT IMPLEMENTED ]"
  echo -e "    Execute restore of backups."
  exit;
}

function trap_err_function() {
  exit_status=$?
    echo -e "\n*** WARNING LINE "$1": Command exited with status "$exit_status" ***\n"
}

function trap_exit_function() {
  exit_status=$?
    echo -e "\n*** FATAL ERROR LINE "$1": Command exited with status "$exit_status" ***\n"
}

function print_version() {
  echo "Backup Script version: "$VERSION
  echo "rdiff-backup local version: "$(rdiff-backup --version)
}

function set_debug() {
  echo "Debug Mode Enabled" | tee -a $LOG
  DEBUG=1
}

function set_mail() {
  echo "Mail Mode Forced" | tee -a $LOG
  MAIL=1
}

function set_verbose() {
  echo "Verbose Mode Enabled" | tee -a $LOG
  VERBOSE=1
}

# conf_parser (  )
# We use this function to do sanity check on configurations,
# set defaults, etc. in one place before starting the
# main backup() function.
function conf_parser() {

  # How much hosts have I configured?
  hosts_conf=$(ls $CONF_DIR | grep -v template.tpl) # we exclude the template from count
  if [[ ${#hosts_conf[@]} -eq 0 ]]; then # if the count is 0 we have to abort
    echo ""
    echo "No host file specified in '$CONF_DIR'"
    echo "Stopping backup"
    echo ""

    exit 1
  fi
}

# perhost_conf_parser (  )
# We use this function to do sanity check on configurations,
# set defaults, etc. on a per host basis. To be used before
# the backup of a single host.
function perhost_conf_parser() {

  # If remote is not set we consider it false
  [[ ${servconf[0]} ]] || $servconf=([0]=false)

  # If sshfs is not set we consider it false
  [[ ${servconf[3]} ]] || $servconf=([3]=false)
  
  # If rpath is not set we default to / (root)
  [[ ${servconf[4]} ]] || $servconf=([4]='/')

  # If I have a per host retention setting
  if [[ ${servconf[5]} ]]; then
    #than set it for further use
    __ret=${servconf[5]}
  #else set it to the global retention setting
  else
    __ret=${RETENTION}
  fi

  return 0
}