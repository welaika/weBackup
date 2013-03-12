#!/bin/bash

#	TODO
#+	script per restore ( da fare con molta cautela )

# Load configuration and libraries
###################################
if [ ! -e "configure" ]; then
	log "*** FATAL ERROR: CONFIGURATION FILES 'configure' CANNOT BE FOUND *** "
	exit 1
fi

. configure
for lib in `ls lib/`; do
	. lib/$lib
done

# Working Directory
WD=$(cd `dirname $0` && pwd)
# Conf Directory
CONF_DIR=$WD"/"$CONF_DIR
# "conf" files
HOSTS=`ls $CONF_DIR`

# Handling of command line arguments
DEBUG=0
VERBOSE=0
MAIL=0

LOG=$(create_log ${WD}/${LOG_MAIN_DIR})

# test if there are backward compatibility problems
###################################################
transitionals

# A sort of getopts
###################################################
if [ $# -eq 0 ]; then
	usage
fi

# attende l'input ed esegue l'azione selezionata
until [[ -z "$1" ]]; do
	case "$1" in
		"--backup") 	exec_backup ;;
		"-b") 				exec_backup ;;
		"--debug") 		set_debug ;;
		"-d") 				set_debug ;;
		"--help") 		usage ;;
		"-h") 				usage ;;
		"--mail") 		set_mail ;;
		"-m") 				set_mail ;;
		"--verbose")	set_verbose ;;
		"-v") 				set_verbose ;;
		"--version") 	print_version ;;
		*) 						usage ;;
	esac
	shift
done

# Here We Go!
###################################################
function exec_backup() {
  test_rdiff
  test_logrotate
  conf_parser
  backup

  if [ $VERBOSE -eq 1 ]; then
    df -h | tee -a $LOG
  else
    df -h >> $LOG
  fi
  
  if [ ! $DEBUG -eq 1 ]; then
    send_mail
  elif [[ $MAIL -eq 1 ]]; then
    send_mail
  fi
  archive_log
}
