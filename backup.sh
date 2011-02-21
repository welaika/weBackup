#!/bin/bash

#	TODO
#+	script per restore ( da fare con molta cautela )
#+	implementare log rotate
#+	aggiungere df -h al log

#
##	FUNCTION DECLARATION
#

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


# Handling function for command line arguments
function exec_backup() {
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

# Load configuration and libraries
if [ ! -e "configure" ]; then
	echo "*** FATAL ERROR: CONFIGURATION FILES 'configure' CANNOT BE FOUND *** "
	exit
fi

. configure
. lib/sysconfig
. lib/function.backup.lib
. lib/function.log.lib
. lib/function.mail.lib


#
##	CODE
#

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

LOG=$(create_log $WD"/"$LOG_MAIN_DIR "" "" $LOG_EXTENSION)

if [ $# -eq 0 ]; then
	usage
fi

# attende l'input ed esegue l'azione selezionata
until [[ -z "$1" ]]; do
	case "$1" in
		"--backup")
			exec_backup
		;;
		"-b")
			exec_backup
		;;
		"--debug")
			set_debug
		;;
		"-d")
			set_debug
		;;
		"--help")
			usage
		;;
		"-h")
			usage
		;;
		"--mail")
			set_mail
		;;
		"-m")
			set_mail
		;;
		"--verbose")
			set_verbose
		;;
		"-v")
			set_verbose
		;;
		"--version")
			print_version
		;;
		
		*)
			usage;;
	esac
	shift
done
