#!/bin/bash
# Script for first deploy of the script. Scope of the script is to:
#+check the presence of rdiff-backup on the system
#+check the presence of ssh
#+check the presence of the $backup_dir (source it from configure)
#   if not create it
#   if unset/null warn the user


