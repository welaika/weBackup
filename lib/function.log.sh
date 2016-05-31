#!/bin/bash
#	Log function library for Backup Script
#
#	Version: 0.4

# create_log ( string dir )
function create_log() {
	local log_dir=$1
  local LOG=${log_dir}/weBackup.log.tmp
  [[ -d ${log_dir} ]] || mkdir -p ${log_dir}
  [[ -f ${log_dir}/weBackup.log.tmp ]] || touch ${log_dir}/weBackup.log.tmp
	 # return log file name
	 #  why echo and not return? I don't know at the moment...:S
	 echo $LOG
}

# logdate ( no args )
# Sets a variable to handle the log lines prefix with [TAG] [date-hour] "
function logdate() {
  today=$(date +%F) #giorno
  ora=$(date +%H:%M:%S) #data
  logtag="[weBackup]"
  
  echo -n "$logtag [$today-$ora] "
}

# test_logrotate( no args )
# Test if logrotate is installed or warn the user. If installed but not configured
#+then it print the configuration in the right place...
function test_logrotate() {
  if [[ ! `which logrotate` ]]; then
    log "WARN: logrotate not installed in your system. Please try \"apt-get install logrotate\" to activate log rotation\n" 1 1;
    return 1
  fi
  if [ ! -f "/etc/logrotate.d/weBackup" ]; then
    if [ -d "/etc/logrotate.d" ]; then  
      log "WARN: logrotate configuration not present. We are creating it at /etc/logrotate.d/weBackup\n" 1 1
        cat <<EOT > /etc/logrotate.d/weBackup
${WD}/${LOG_MAIN_DIR}/*.log {
    weekly
    missingok
    rotate 10
    compress
    delaycompress
    notifempty
    create 640 root adm
}
EOT
    else
      echo -e "WARN: we cannot find the logrotate conf dir in the usual path. Please, make yourself a logrotate config file with these parameters:\n"
      cat <<EOT
${WD}/${LOG_MAIN_DIR}/*.log {
    weekly
    missingok
    rotate 10
    compress
    delaycompress
    notifempty
    create 640 root adm
}
EOT
    return 1
    
    fi
  fi
  
  return 0
}

# logcmd( command_in_string_form, 1 )
# se passato il secondo argomento, allora attiva l'escape dei backspaces sull'echo
# se la variabile $VERBOSE è uguale a 1 allora stampo anche a video
# logcmd() serve ad inserire nei log l'output (1 e 2) dei comandi
function logcmd() {
  [[ $2 ]] && stampa="echo -e" || stampa="echo"
  logdate >> $LOG
  $1 >> $LOG 2>&1
  [[ $VERBOSE -eq 1 || $DEBUG -eq 1 ]] && (
      logdate
      $stampa "$1"
    )
}

# log( text_string, 1 )
# se passato il secondo argomento, allora attiva l'escape dei backspaces sull'echo
# se la variabile $VERBOSE è uguale a 1 allora stampo anche a video
# log() serve ad inserire nei log stringhe di testo arbitrarie
function log() {
  [[ $2 ]] && stampa="echo -e" || stampa="echo"
    logdate >> $LOG
    $stampa "$1" >> $LOG
  [[ $VERBOSE -eq 1 || $DEBUG -eq 1 ]] && (
      logdate
      $stampa "$1"
    )
}

# sendmail (  )
function send_mail() {
  if [[ $DEBUG -eq 1 && $MAIL -ne 1 ]] || [[ $MAIL -ne 1 ]]; then return 0; fi

  for mail in ${MAIL_ADDR[*]}
  	do
      if [[ ${SMTP_HOST} ]]; then
          env MAILRC=/dev/null from=${MAIL_FROM} \
          smtp=${SMTP_HOST} smtp-auth-user=${SMTP_USER} \
          smtp-auth-password=${SMTP_PASSWORD} smtp-auth=${SMTP_AUTH} \
          mailx -n -s "Backup Report" $mail < ${LOG}
      else
        mail -s $MAIL_SUBJ $mail < ${LOG}
      fi
  	done
}

# archive_log (  )
function archive_log() {
	cat $LOG >> ${WD}/${LOG_MAIN_DIR}/weBackup.log
	rm -f $LOG
}
