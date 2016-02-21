# ORP Remote Relay Module
The ORP Remote Relay Module is a SVXLink module to add features to OpenRepeater/SVXLink to control relays by DTMF tones remotely. It based on code forked from Module-Remote-Relay by F8ASB but modified to be better suited for used with the OpenRepeater Project.

## Installation Instructions

### Copy Module Code Files
RemoteRelay.tcl   -> /usr/share/svxlink/events.d
ModuleRemoteRelay->/usr/share/svxlink/modules.d
/etc/openrepeater/svxlink/svxlink.d/ModuleRemoteRelay.conf

### Copy Audio Files
For example for french language: /usr/share/svxlink/sounds/fr_FR/RemoteRelay

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
