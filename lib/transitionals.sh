# This is a library for functions to handle updates between versions
# of the script when we can't implement backwards compatible features.
# they all must be called within the transitionals() function that is
# placed at the beginning of the backup.sh script.

function transitionals(){
  tr__perhostretention
  return 0
}

# tr__perhostretention
# no args
# check if the host.conf files supports the per host retention or log down an alert
function tr__perhostretention(){
  for host in $HOSTS; do
    . ${CONF_DIR}/${host}/host.conf
    ${servconf[5]} || (
        log <<EOT
          [ALERT]
          ${host}/host.conf seems out of date, since it has not retention
          setting. Please take a look and if it has not add these lines at
          the end of the array inside the file:

          #retention
          ##########
          # Set the retention of the backups for the specific host in weeks. MUST be an
          # integer (e.g.: 2 stands for 2 weeks). Incremental backups older than $retention
          # will be deleted. Default is 2 week.
          [5]=2

          You can follow template.tpl/host.conf as example. If you won't do this,
          the retention time will be set as 2 weeks.

EOT
      )
  done
}