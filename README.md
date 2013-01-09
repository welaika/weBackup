## Backup Script

### Using rdiff-backup create backup of remote host in local folder, of a local folder in another local folder or mount a remote folder using sshfs and back it up. For the last one OpenSSH-server needed on the remote machine.


INSTALL
-------

1. Untar package or
    ```bash
    git clone git://github.com/welaika/weBackup.git"
    ```
2. Install rdiff-backup on local machine
3. Install an heirloom-mailx (debian family: apt-get install
  heirloom-mailx). Then go to the "configure" file in the script's
  root folder and set up your external SMTP.
4. Install rdiff-backup on every remote machine you need to backup or...
5. If you haven't administrator privileges on your remote machines,
    we can work it out using sshfs. Please install it on your server
    system with "apt-get install sshfs" for debian-based OS or equivalent
    command.
6. Have a "configure" file
    
    ```bash
    cp configure.tpl configure
    ```

  read and set it up

HOW TO - HOW IT WORKS
---------------------

To let rdiff-backup perform backups, a ssh access to the machine that 
needs backup must be provided. rdiff-backup use 'root' account to
connect using ssh ( and this cannot be changed ) so the best way to
accomplish this is enabling ssh login to root accont on server only 
with ssh keys ( disabling access with password ). For references:
http://bit.ly/qdECva
http://bit.ly/qMbbVG

HOW TO - CONFIGURE A HOST
------------------------

Go in the base directory of the script and type
./addhost.sh
An interactive script will guide you through the creation of the host
configuration. At the end of this process it will remind you to set up
pubkey ssh autentication (not yet implemented an automatic process) and
to set up the globbing-file-list in globbing.conf.
REMEBER that if you want to exclude a dir you have, e.g. to exclude
/var/log, to write:

    - /var/log
    /var

in the right order, with the exclusion of a deepest path before the
inclusione of a higher one. That's ok? If not you have to study a bit
of rdiff-backup doc. See below for references.


HOW TO - DO A BACKUP
------------------------

From the scripts basedir run script

```bash
./backup.sh [OPTIONS]
```

See ./backup.sh -h for list of options

REFERENCES
----------

http://www.nongnu.org/rdiff-backup/
http://wiki.rdiff-backup.org/wiki/index.php/BackupSomeDirectoriesOnly
