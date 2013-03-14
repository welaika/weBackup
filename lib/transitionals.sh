# This is a library for functions to handle updates between versions
# of the script when we can't implement backwards compatible features.
# they all must be called within the transitionals() function that is
# placed at the beginning of the backup.sh script.

function transitionals(){
  tr__perhostretention
  tr__retentionsyntax
  tr__updatehostconf
  return 0
}

# tr__perhostretention
# no args
# check if the host.conf files supports the per host retention or log down an alert
function tr__perhostretention(){
  for host in $HOSTS; do
    . ${CONF_DIR}/${host}/host.conf
    [[ ${servconf[5]} ]] || (
      read -r -d '' message <<EOT
[ALERT]\n
${host}/host.conf seems out of date, since it has not retention\n
setting. Please take a look and if it has not add these lines at\n
the end of the array inside the file:\n
\n
#retention\n
##########\n
# Set the retention of the backups for the specific host in weeks. MUST be an\n
# integer (e.g.: 2 stands for 2 weeks). Incremental backups older than $retention\n
# will be deleted. Default is 2 week.\n
[5]=2\n
\n
You can follow template.tpl/host.conf as example. If you won't do this,\n
the retention time will be set as 2 weeks.\n
\n
EOT
        log "$message" 1
    )
  done
}

function tr__retentionsyntax() {
  for host in $HOSTS; do
    . ${CONF_DIR}/${host}/host.conf
    [[ ${servconf[5]} =~ ^[0-9]+$ ]] && (
      read -r -d '' message <<EOT
[ALERT]\n
${host}/host.conf seems containing errors, since retention is numeric only.\n
Read the file comments to learn more about retention units W, D, ecc. If in doubt\n
put W as unit as it stands for weeks
\n
EOT
      log "$message" 1
    )
  done
}

function tr__updatehostconf() {
  for host in $HOSTS; do
    # If the checked host's host.conf is identical to the template one, then leave function.
    #+configurations values are not checked here: just texts. We consider that the order of
    #+confs is fixed forever...and thay are actually
    [[ `diff <(cat conf/${host}/host.conf | egrep -v '^\[.*') <(cat conf/template.tpl/host.conf | egrep -v '^\[.*')` ]] || continue
    [[ $host == 'template.tpl' ]] && continue; # leave if template
    #User configurations are saved in array
    arrayConf=(`cat conf/${host}/host.conf | egrep '^\[.*'`)
    #host.conf is updated
    mv ${CONF_DIR}/$host/host.conf ${CONF_DIR}/$host/host.conf.$(date +%F%H%M%S)
    cp ${CONF_DIR}/template.tpl/host.conf ${CONF_DIR}/$host/host.conf

    #User configurations are reported in the updated file
    for element in ${arrayConf[@]}; do
      element=${element//[/\\[}
      element=${element//]/\\]}
      sed -i "s/${element:0:6}/$element/" ${CONF_DIR}/$host/host.conf
    done
  done
}