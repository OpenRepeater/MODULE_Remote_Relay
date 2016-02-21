# ORP Remote Relay Module
Module Remote Relay for Svxlink to drive 4 relays by DTMF Code
forked from Module-Remote-Relay F8ASB

## Installation Instructions

### Modifying SVXLINK.CONF

Note: These instructions are currently for bare SVXLink installations. For OpenRepeater setups, you will need to hard code these modifications in the svxlink_update.php file that writes the config file, otherwise these setting will be overwritten when settings are changed in the web interface.

First add in the module name to the list of Modules

MODULES=ModuleHelp,ModuleParrot,ModuleRemoteRelay

Secondly, create a config file for the module. For OpenRepeater, the path would be

/etc/openrepeater/svxlink/svxlink.d/ModuleRemoteRelay.conf

…and the contents:

[ModuleRemoteRelay]
NAME=RemoteRelay
PLUGIN_NAME=Tcl
ID=9
TIMEOUT=60
