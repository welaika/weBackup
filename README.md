## weBackup

#### Wraps rdiff-backup and manage multiple host backup to add and remove them easily.

HOW TO - INSTALL
----------------

1. Untar package or
    
        git clone git://github.com/welaika/weBackup.git

2. Install rdiff-backup on local machine
3. Install an heirloom-mailx (debian family: apt-get install
  heirloom-mailx). Then go to the "configure" file in the script's
  root folder and set up your external SMTP.
4. Install rdiff-backup on every remote machine you need to backup or...
    (ehi wait! Are you using a MediaTemple Grid-Service? Take a look [here](http://pisadmin.welaika.com/post/44637112969/mt-gs-bk-our-definitive-mt-grid-service-backup))
5. If you cannot install rdiff-backup on your remote machines,
    we can work it out using sshfs. Please install it on your server
    system (this one!) with "apt-get install sshfs" for debian-based OS or equivalent
    command.
6. Have a "configure" file
        
        cp configure.tpl configure

  read and set it up

HOW TO - HOW IT WORKS
---------------------

Script structure dissection and explanation

    ├── addhost.sh

Invoke this to add a host to backups. More follows in this readme

    ├── backup.sh

This is the main mackup script. Nothing to be configured here. Read just
if your interest. Usage follows in this readme

    ├── CHANGELOG.md

A changelog bad emulation

    ├── conf
    │   ├── example.com
    │   │   ├── globbing.conf
    │   │   ├── host.conf
    │   │   └── template.tpl
    │   │       ├── globbing.conf
    │   │       └── host.conf
    │   └── template.tpl
    │       ├── globbing.conf
    │       └── host.conf

The addhost.sh produces host configuration in thi directory. Each subdir
is a host. You can rename a dir hiding it (e.g.: .example.com) to disable
backups for that host.
For each subdir we have two configuration files. We'll tell more about them
in a while.

    ├── configure.tpl

Main configuration file. SO MUCH IMPORTANT! We mentioned it before in _HOW TO INSTALL_

    ├── lib
    │   ├── function.backup.lib
    │   ├── function.log.lib
    │   ├── settings.sh
    │   ├── sysconfig (deprecated)
    │   └── transitionals.sh

These are libraries of bash functions.

    ├── log
    │   └── weBackup.log

Logs. The script will try to automatically configure logrotate to handle
log rotation inside thi folder

    └── README.md

Just what are you reading ;)

HOW TO - CONFIGURE A HOST
------------------------

#### addhost.sh

Go in weBackup's base directory and type

    ./addhost.sh

An interactive script will guide you through the creation of the host
configuration. At the end of this process it will remind you to set up
pubkey ssh autentication (not yet implemented an automatic process) and
to set up the globbing-file-list in globbing.conf. Take a look also at
_conf/hostname/host.conf_ to see configured host and comments about options.

#### globbing.conf

This is an rdiff internal, so you should have to study a bit
of rdiff-backup doc. See below for references.
Any way a couple of tips follows.

Overall if you wont specify nothing here, the whole filesystem starting
from the specified basedir (rpath in host.conf) will be backed up.
If you like to backup just some directories, assuming my basedir is
```/home/pioneerskies```, write something like this:

    /home/pioneerskies/dev
    /home/pioneerskies/web
    /home/pioneerskies/git
    - **

this will backup _dev_, _web_ and _git_ into your $BACKUP_DIR, ecluding
all other path.

REMEBER that if you want to exclude a specific dir inside a dir you want
to backup you have, e.g.:
    
    /home/pioneerskies/dev
    /home/pioneerskies/web
    - /home/pioneerskies/git/weBackup
    /home/pioneerskies/git
    - **

in the right order, with the exclusion of a deepest path before the
inclusione of a higher one. That's ok?

#### ssh-copy-id

To let rdiff-backup perform backups of remote host, a ssh access
to the remote host must be provided. rdiff-backup and SSHFS use ssh to
connect to remote host, so is requested enabling pubkey auth for your
user accont on server, disabling access with password.
The command is:

    ssh-copy-id user@example.com

then follow on screen istructions.

For further references:

* <http://bit.ly/qdECva>
* <http://bit.ly/qMbbVG>


HOW TO - DO A BACKUP
------------------------

From the scripts basedir run script

```bash
./backup.sh [OPTIONS]
```

See ./backup.sh -h for list of options. Common options are ```./backup.sh -v -b```

You can now setup a *single cronjob to manage all your backups*:

    # m h  dom mon dow   command
    0 21 * * * bash -l -c "cd /root/weBackup && ./backup.sh -v -b"

```bash -l -c``` is not mandatory: I use it usually, so is in the example ;)


REFERENCES
----------

<http://www.nongnu.org/rdiff-backup/>

<http://wiki.rdiff-backup.org/wiki/index.php/BackupSomeDirectoriesOnly>
