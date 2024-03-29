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

  COMMAND_EXIT_STATUS=$?

  [[ $VERBOSE -eq 1 || $DEBUG -eq 1 ]] && (
      logdate
      $stampa "$1"
    )

  return $COMMAND_EXIT_STATUS
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

function chat_notification() {
  COMMAND_EXIT_STATUS=$1
  HOST=$2

  if [[ ${servconf[7]} == "false" ]]; then
    return 0;
  fi

  if [[ ${servconf[7]} == "hipchat" ]]; then
    HC_ROOM_NAME=${servconf[8]}
    HC_AUTH_TOKEN=${servconf[9]}

    if test -z $HC_ROOM_NAME; then
      log "Non e' impostata la room name per HipChat"
      return 1;
    fi

    if test -z $HC_AUTH_TOKEN; then
      log "Non e' impostato il token per HipChat"
      return 1;
    fi

    hipchat_notification $COMMAND_EXIT_STATUS $HOST
    return 0;
  fi

  if [[ ${servconf[7]} == "ryver" ]]; then
    RY_WEBHOOK=${servconf[10]}

    if test -z $RY_WEBHOOK; then
      log "Non e' impostato il WebHook per Ryver"
      return 1;
    fi

    ryver_notification $COMMAND_EXIT_STATUS $HOST
    return 0;
  fi

  if [[ ${servconf[7]} == "msteams" ]]; then
    MSTEAMS_WEBHOOK=${servconf[11]}

    if test -z $MSTEAMS_WEBHOOK; then
      log "Non e' impostato il WebHook per MS Teams"
      return 1;
    fi

    msteams_notification $COMMAND_EXIT_STATUS $HOST
    return 0;
  fi

  log "La configurazione delle notifiche via chat non e' corretta"
  return 1;
}

function ryver_notification() {
  COMMAND_EXIT_STATUS=$1
  HOST=$2

  if [[ $COMMAND_EXIT_STATUS -eq 0 ]]; then
    MESSAGE=":white_check_mark: Backup riuscito
> Host: $HOST"
  else
    MESSAGE=":skull_and_crossbones: Backup fallito
> Host: $HOST"
  fi

  curl -X POST -H "Content-Type: text/plain; charset=utf-8" \
    -d "${MESSAGE}" ${RY_WEBHOOK}
}

function msteams_notification() {
  COMMAND_EXIT_STATUS=$1
  HOST=$2

  if [[ $COMMAND_EXIT_STATUS -eq 0 ]]; then
    COLOR="7cfc00"
    MESSAGE="✅ Backup riuscito"
  else
    COLOR="ff0000"
    MESSAGE="☠️ Backup fallito"
  fi

  curl -X POST -H "Content-Type: application/json; charset=utf-8" \
    -d "{ \"summary\": \"Card weBackup\", \"themeColor\": \"$COLOR\", \"title\": \"Offsite backup per ${HOST}\", \"sections\": [ { \"activityTitle\": \"weBackup\", \"activitySubtitle\": \"\", \"activityImage\": \"https://p195.p4.n0.cdn.getcloudapp.com/items/Z4ujjqz1/0384897c-a30b-48e7-ab29-77e929cbbe21.png?v=90283dc597ca3ee15017dedefc9fc1c8\", \"facts\": [ { \"name\": \"Host:\", \"value\": \"${HOST}\" }, { \"name\": \"Stato:\", \"value\": \"${MESSAGE}\" } ], \"text\": \"\" } ], \"potentialAction\": [] }" "${MSTEAMS_WEBHOOK}"
}

function hipchat_notification() {
  test -z ${HC_ROOM_NAME} && return 0; #silently return if room name is not set

  COMMAND_EXIT_STATUS=$1
  HOST=$2

  if [[ $COMMAND_EXIT_STATUS -eq 0 ]]; then
    COLOR='green'
    MESSAGE="Backup di $HOST terminato con successo"
    NOTIFY='false'
  else
    COLOR='red'
    MESSAGE="Sembra essere fallito il backup per l'host $HOST"
    NOTIFY='true'
  fi

  curl -X POST -H "Authorization: Bearer $HC_AUTH_TOKEN" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "{ \"color\": \"$COLOR\", \"message\": \"$MESSAGE\", \"notify\": \"$NOTIFY\", \"message_format\": \"text\" }" "https://api.hipchat.com/v2/room/${HC_ROOM_NAME}/notification"
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
