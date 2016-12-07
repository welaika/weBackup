#!/bin/bash
#	Backup function library for weBackup
#
#	Version: 0.5

# backup (  )
# The main backup function. Tass!
function backup() {
  log "Backup local disk: $BACKUP_DIR"
	log "Backup local conf: $CONF_DIR"
	log "Log file         : $LOG"

	log "Hosts:"
	for host in `ls $CONF_DIR`
	do
	  #Parsing the various hosts, ignore the template file plz
	  if [ $host == 'template.tpl' ]; then
	    continue
    fi
	  test_conf_dir $host || continue
		log "$host"
	done

	log "Starting backup"
	backup_delay $DELAY 1

  # Start cycle in each configured host
	for host in `ls $CONF_DIR`
	do
	  #Parsing the various hosts, ignore the template file plz
	  if [ $host == 'template.tpl' ]; then
	    continue
    fi

	  test_conf_dir $host || continue #test if both per host conf files exists
	  . ${CONF_DIR}/${host}/host.conf #then source one of them
  	log "Using $host configuration"

    perhost_conf_parser

    if ${servconf[6]}; then
      local CURRENT_BACKUP_DIR=${BACKUP_DIR}/${servconf[6]}
    else
      local CURRENT_BACKUP_DIR=${BACKUP_DIR}
    fi

	  if ${servconf[0]}; then #if remote
  	  user="${servconf[1]}@" #set the proper username
	  else #if local
	    user="" #no username needed
	    # For remotly mounted sshfs file systems we'll
	    #+have an ad hoc username from host.conf
    fi

		log "Inizio Backup per: $host\n" 1

		##IF DEBUG ONLY (dry-run)
		if [ $DEBUG -eq 1 ]; then
      dry_run
    ## ELSE IT IS REAL BACKUP
    else
			test_dest_dir $host
		  # If my dir is a sshfsmounted dir than handle mount
		  #+operations with the proper function
		  if ${servconf[3]}; then
        mount_sshfs || continue
  		  logcmd "rdiff-backup --print-statistics --exclude-special-files --verbosity $RDIFF_VERBOSITY --include-globbing-filelist ${CONF_DIR}/${host}/globbing.conf ${servconf[2]} ${CURRENT_BACKUP_DIR}/${host}"

        hipchat_notification $? $host

        delete_older ${host}
      # else if is remote
      elif ${servconf[0]}; then
        logcmd "rdiff-backup --print-statistics --exclude-special-files --verbosity $RDIFF_VERBOSITY --include-globbing-filelist ${CONF_DIR}/${host}/globbing.conf ${user}${host}::${servconf[4]} ${CURRENT_BACKUP_DIR}/${host}"

        hipchat_notification $? $host

        delete_older ${host}
      # last option is a local directory
      else
        logcmd "rdiff-backup --print-statistics --exclude-special-files --verbosity $RDIFF_VERBOSITY --include-globbing-filelist ${CONF_DIR}/${host}/globbing.conf ${servconf[2]} ${CURRENT_BACKUP_DIR}/${host}"

        hipchat_notification $? $host

        delete_older ${host}
      fi
    fi

    # If we have $mounted true, so we have to unmount the dir
    if [[ $mounted ]]; then
      `which fusermount` -u ${servconf[2]}
      log "Unmounted ${servconf[2]}"
      # and unset it
      unset mounted
    fi
  done
}

function dry_run() {
  if ${servconf[6]}; then
    local CURRENT_BACKUP_DIR=${BACKUP_DIR}/${servconf[6]}
  else
    local CURRENT_BACKUP_DIR=${BACKUP_DIR}
  fi

  if ${servconf[3]}; then #if a remotely mounted sshfs filesystem
    mount_sshfs ${user}${host}::${servconf[4]} ${servconf[2]}
    log "TESTING mountpoint /mnt/$host"
    mountpoint ${servconf[2]} > /dev/null
    if [[ $? != 0 ]]; then #let's look the exit status
      log "ERROR: mount of the remote filesystem went bad; problem probably genereted remotly. Aborting"
    fi
  #if remote
  elif ${servconf[0]}; then
    log "TESTING $host"
    log "rdiff-backup --print-statistics --exclude-special-files --verbosity $RDIFF_VERBOSITY --include-globbing-filelist ${CONF_DIR}/${host}/globbing.conf ${user}${host}::${servconf[4]} ${CURRENT_BACKUP_DIR}/${host}"
    logcmd "rdiff-backup --test-server ${user}${host}::${servconf[4]}"
    hipchat_notification $? $host
  # last option is a local directory
  else
    log "TESTING $host"
    log "rdiff-backup --print-statistics --exclude-special-files --verbosity $RDIFF_VERBOSITY --include-globbing-filelist ${CONF_DIR}/${host}/globbing.conf ${servconf[2]} ${CURRENT_BACKUP_DIR}/${host}"
    hipchat_notification $? $host
  fi
}

# delete_older ( $host )
# Execs rdiff-backup --remove-older-than ${__ret} for the specified $host
function delete_older() {
  if ${servconf[6]}; then
    local CURRENT_BACKUP_DIR=${BACKUP_DIR}/${servconf[6]}
  else
    local CURRENT_BACKUP_DIR=${BACKUP_DIR}
  fi

  if [[ ! $1 ]]; then
    log "ERROR: Function delete_older() needs an argument"
    return
  fi
  [[ $DELETEOLDER ]] && logcmd "rdiff-backup --force --remove-older-than ${__ret} ${CURRENT_BACKUP_DIR}/$1"
}

# test_rdiff (  )
# Have we rdiff-backup installed?
function test_rdiff() {
  if [[ ! `which rdiff-backup` ]]; then
    log "Hey! It seems that you have not installed rdiff-backup yet!"
    log "It should be as easy as"
    log "  apt-get install rdiff-backup"
    log "or, if in Fedora family after enabled EPEL repos"
    log "  yum install rdiff-backup\n\n" 1

    exit 1
  fi
}

# test_conf_dir ( host )
# Test if the needed config files exist
function test_conf_dir(){
  if [ ! -f ${CONF_DIR}/$1/globbing.conf ] || [ ! -f ${CONF_DIR}/$1/host.conf ]; then
    log "Missing configuration files for host ${1}. Aborting"
    return 1
  fi

  return 0
}

# test_dest_dir ( string name )
# Test if backup destination directory exists and if not
#+create it.
function test_dest_dir() {
  if ${servconf[6]}; then
    local dir=${BACKUP_DIR}/${servconf[6]}/${1}
  else
    local dir=${BACKUP_DIR}/${1}
  fi


	if [ -d $dir ]; then
  	log "> Backup directory for host exists"
	else
		log "> Backup directory for host does not exists; creating..."
		mkdir -p $dir

		if [ -d $dir ]; then
			log "> Created: $dir"
		else
			log "> FAILED! Backup ABORTED ( err: "$?" )"
			exit $?
		fi
  fi

	return 0
}

# delay ( int time, bool stdout )
function backup_delay() {
	local delay_time=$1
	local stdout=$2

	for i in `seq $delay_time -1 1`
	do
		if [ $stdout -eq 1 ]; then
			echo -e -n "."
		fi
		sleep 1
	done

	if [ $stdout -eq 1 ]; then
		echo -e "\n"
	fi
}

# mount_sshfs ( user@host:dir mountpoint )
# This function will be valid only inside backup() function
#+due to use of certain variables setted there...
function mount_sshfs(){
  if ! ${servconf[0]}; then
    if ${servconf[3]}; then
      if [[ ! `which sshfs` ]]; then
        log "FATAL: sshfs is not installed on the system. Aborting... \n try apt-get install sshfs" 1
        return 1
      fi

      if [[ ! -d ${servconf[2]} ]]; then mkdir ${servconf[2]}; fi

      # If at this point for any reason of the hell the mountpoint is already mounted, unmount it
      #+befor the nect mount
      if mountpoint ${servconf[2]}; then
        `which fusermount` -u ${servconf[2]};
        log "Unmounted ${servconf[2]}: it was already mounted for some reason"
      fi

      `which sshfs` ${servconf[1]}@${host}:${servconf[4]} ${servconf[2]} -C

      if [[ $? != 0 ]]; then
        log "FATAL: mount of the remote filesystem went bad; problem probably genereted remotly. Aborting"
        return 1
      fi
      mountpoint ${servconf[2]} #double control of the mount is paranoic?
      if [[ $? != 0 ]]; then
        log "FATAL: mount of the remote filesystem went bad; problem probably genereted remotly. Aborting"
        return 1
      else
        # At the end of the backup process will be a pleasure to have a quick way to verify
        #+if the dir is alredy mounted to unmount it before process another host/dir.
        #+Only to minimize risks that someone could have access to the remote files from the backup server
        #+and potentially put the word END on clients data... >_>
        mounted=true
      fi
    fi
  fi
  return 0
}

