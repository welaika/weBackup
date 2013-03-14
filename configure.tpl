##	Config for backup.sh 

# Backup save directory
	BACKUP_DIR=""

# Mail addresses to send log after backup complete ( can be single 
#+	address or array
	MAIL_ADDR=( "" )
	MAIL_SUBJ=''
  MAIL_FROM=''

#EXTERNAL SMTP CONFIGS
# If not setted, we'll use your system's "mail" command to send out
  SMTP_HOST=""
  SMTP_USER=""
  SMTP_PASSWORD=""
  SMTP_AUTH=""

# Activate retention time
#   You can decide whether or not to delete incremets older than
#+  $RETENTION time (see below). If you won't activate this pay attention
#+  to the disk space that will be getting bigger.
#   Set this variable to TRUE to activate or leave it blank switch off deletion.
#   Ex: DELETEOLDER=""

  DELETEOLDER="TRUE"

# Retention Time
#  You can set the retention time, above which rdiff-backup increments
#+ will not be conserved. The format of this variable MUST be as stated 
#+ in rdiff-backup manual e.g.: 2D means  two days, 2W means two weeks ecc.

#N.B.: at the moment is not possible to disable deletion of increments older
#+ than $RETENTION...consider it a ToDo

  RETENTION="2W"


# EDIT ONLY IF YOU KNOW WAHT YOU ARE DOIING ---------------------------

# Folder from which load configuration file
	CONF_DIR="conf"

# Log file info
	LOG_MAIN_DIR="log"
	LOG_EXTENSION=".log"
	
	# A separator must be present
	#LOG_PREFIX=""
	#LOG_SUFFIX=""

	
