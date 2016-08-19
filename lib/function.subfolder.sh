function check_or_create_subfolder() {
  SUBFOLDER=$1

  if [ test -d $SUBFOLDER ]; then
    return 0
  else
    mkdir $SUBFOLDER
  fi
}
