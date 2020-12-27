
<!--#echo json="package.json" key="name" underline="=" -->
ubborg-sysd-murmurd-pmb
=======================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Ubborg config generator for murmurd (mumble-server VOIP) with better systemd
startup.
<!--/#echo -->



API
---

This module exports one function:

### setupMurmurd(bun, opt)

`bun` is the ubborg bundle on whose behalf all requests shall be issued.

`opt` is an optional options object that supports these optional keys:

* `debPkg`: Whether and which apt package to install as the server.
  * `true` (default): Install the default package.
  * `false`: Don't install, just prepare for installing it.
  * any string or array: Use these package names.
* `userIdNum`: UID to use for the murmur user account.
  `0` (default) = Don't create the account.
* `groupIdNum`: GID to use for the murmur user group.
  Ignored unless `uid` is set, too. `0` (defalt) = same as UID.




<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
