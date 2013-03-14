This is a ChangeLog...almost. We track only big changes in help
of our poor memory. So don't expect a lot of infos here ;)

Mar2013
-------

Mostly a refactor, but also with some features. But also better coding
is a serius feature!

* remote basedir is now configurable in host.conf
* now functions libraries are more modular and splitted in significant files
* implemented some sanity check on host.conf parameters
* comments in host.conf reviewd (more to come here)
* good refactorization
  * much more linear logic
  * much less awful symbols and non semantic functions
  * much less readable code. You can read backup.sh and comprehend it ;)
  * log and logcmd functions now handle internally VERBOSE output
* VERSBOSE has changed rules: quite all is always logged, if VERBOSE
  is also printed on STOUD. Just as you expect I think
* now retention is all customizable also with time units
* fixed bugs in debug flow
* when first run, now all dir should be correctly created if not present
* heavy rewritten README.md: more explanatory and complete
* now if updated host.conf template, all the files will be updated. Obviusly
  configurations will be maintained ;)


Gen2012
-------

* Project renamed in weBackup. Niceier ;)
* Per host retention setting implementation

Oct2012
-------

We've switched to heirloom-mailx from postfix because mailx
is lighter than hell, it doesn't need system configuration, it
takes a bunch of directives directly from CLI; so it suits best
in scripts. Even more it is present in almost all distribuition. 
Overall we've pushed some sweet new code in the mail sender
function, so that it handle sending mail with external SMTP with
authentication out of the box. If configuration is present in "configure" file

    #EXTERNAL SMTP CONFIGS
    SMTP_HOST=""
    SMTP_USER=""
    SMTP_PASSWORD=""
    SMTP_AUTH=""

they will be used. We encourage you to use them and not relay on the
local system mail sender.