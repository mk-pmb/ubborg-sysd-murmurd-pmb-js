
Configuring the systemd wrapper
-------------------------------

There are three important concepts at work here:

* The _instance directory_, i.e. `/var/lib/mumble-server/${svcName}`.
  * This will be the working directory where the server will be run.
  * It's also the default place for the database.
* The systemd _service unit_ file created from
  [`src/svcUnitTemplate.mjs`](../src/svcUnitTemplate.mjs).
* The _wrapper_ script [`src/sysdwrap.sh`](../src/sysdwrap.sh).
  Look here for default settings.

The condition setting in the _service unit_ ensures that the server
is only run on hosts where the _instance directory_ exists.

There, the _wrapper_ will create an ini file based on

* the default settings. (weakest)
* ini files in subdirectory `cfg` (`${instanceDir}/cfg/*.ini`),
  so you can partially override specific settings using files that may or
  may not be there, just like with systemd drop-in files.
  * Ice settings don't need a section; they're identified by their
    names starting with `Ice.`.
  * Indentation is ignored.
  * Space characters around the first `=` in each line will be ignored.
  * Line comments are ignored. That's any line starting with `;` or `#`.
* environment variables starting with `murmur_`.
  Usually you won't need this, but maybe you like actual systemd drop-in files
  better than the `cfg/*.ini` method.
  * For keys that contain dots (probably Ice settings), you have to replace
    those dots with double underscores (`__`).
  * Remember to `systemctl daemon-reload` before you
    `systemctl restart $svcName.service`.

… and then invoke a murmurd for that generated ini file.




