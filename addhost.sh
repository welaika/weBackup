#!/bin/bash
# Script to set up a new host backup
# At the moment you we have no way to control il ssh-key are well setted
#+and I don't know if I'll implement it... :s

. configure

echo -ne "Hi guy! Do  you want to set up a now host backup? [y] [n]: "
read go

if [[ $go != 'n' ]] && [[ $go != 'y' ]]; then
  echo -e "That was only the first answer...>_> Please, retry and type y for yes or n for no\n"; exit 1
elif [[ $go == 'n' ]]; then
  echo -e "Mmmm, ok...see you"; exit 0
fi

echo -ne "What is the name of the host to add? If it is a remote site USE its DOMAIN NAME: "
read host

hostconfig=${CONF_DIR}/${host}/host.conf
cp -r $CONF_DIR/template.tpl ${CONF_DIR}/${host}

# getconf ( string array_to_configure, string substitution )
function getconf(){
  sed -i "s/^\[$1\]=$/\[$1\]=$2/" $hostconfig
  return 0
}

echo -ne "Is the host a remote host with rdiff-backup installed? [y] [n]: "
read remote

if [[ $remote == 'n' ]]; then
  getconf 0 false
  echo -ne "Ok, we have to backup a local directory or a remote one\nmounted locally with sshfs? [local] [sshfs]: "
  read sshfs
  
  if [[ $sshfs == "" ]]; then
    
    echo -e "That was not an optional to follow instructions... Please restart the script now... >_>\n"; exit 1
  
  elif [[ $sshfs == 'local' ]]; then
    getconf 3 false
    
    echo -ne "Please, specify the path of the directory to backup.\nStart with / and omit the trailing slash: "
    read path
    
    if [[ "$path" == "" ]]; then
      echo -e "Path was not an optional... Please restart the script now... >_>\n"
      exit 1
    else   
      getconf 2 $path
    fi
    
  elif [[ $sshfs == 'sshfs' ]]; then
    getconf 3 true
    
    echo -ne "Please, specify the path where you want to mount the remote directort.\nStart with / and omit the trailing slash: "
    read path
    
    [[ $path ]] || echo -e "Path was not an optional... Please restart the script now... >_>\n"; exit 1
    getconf 2 $path
    
    echo -ne "What is the name of the user you want to use\nto mount to the remote dir using sshfs (your ssh user)? "
    read user
    
    [[ $user ]] || echo -e "Username was not an optional... Please restart the script now... >_>\n"; exit 1
    getconf 1 $user
      
  fi
  
elif [[ remote == 'y' ]]; then
  getconf 0 true
  echo -ne "What is the name of the user you want to use\nto connect to the remote host? "
  read user
  
  [[ $user ]] || echo -e "Username was not an optional... Please restart the script now... >_>\n"; exit 1
  sed -i "s/\[1\]=/\[1\]=$user/" ${CONF_DIR}/${host}/host.conf
fi
