# ORP Remote Relay Module
The ORP Remote Relay Module is a SVXLink module to add features to OpenRepeater/SVXLink to control relays by DTMF tones remotely. It based on code forked from Module-Remote-Relay by F8ASB but modified to be better suited for used with the OpenRepeater Project.

## Features
* SVXLink Module
* Control of 1 to 8 relays
* Allows individual or mass control of relays: On/Off/Momenentary
* Supports active high and active low relay boards (defined by OS)
* Optional Access Restriction (Pin Code)
* Definable momentary delay (ms)
* Optional setting to turn off all relays when module is deactived or times out.
* For mass operations, relays turn on or off in a quick sequential order (100ms). 
* Included test command to use to ensure relays are connected/setup properly. 

## Requirements
* SVXLink
* Appropriate sound clips generated for your language using the same file structure provided in the samples.
* ARM Based board with GPIO header
* Debian OS with gpio support (/sys/class/gpio/)

## Installation Instructions

### Copy Module Code Files
* RemoteRelay.tcl   -> /usr/share/svxlink/events.d/RemoteRelay.tcl
* ModuleRemoteRelay.tcl -> /usr/share/svxlink/modules.d/ModuleRemoteRelay.tcl
* ModuleRemoteRelay.conf -> /etc/openrepeater/svxlink/svxlink.d/ModuleRemoteRelay.conf

### Copy Audio Files
Copy the contents of the appropriate language folder in github to the correct system folder. For example for English language: /usr/share/svxlink/sounds/en_US/RemoteRelays

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

## Usage
0# Help Module
	9# - Plays Help File

9# To Active Relay Module (or whatever number is set in config file.)
	0# - Speaks state of all relays (On/Off) as defined in config
	10# - Relay 1 Off
	11# - Relay 1 On
	12# - Relay 1 Momentary

	20# - Relay 2 Off
	21# - Relay 2 On
	22# - Relay 2 Momentary

	[…]

	80# - Relay 8 Off
	81# - Relay 8 On
	82# - Relay 8 Momentary

	(1-8 relays can be defined)

	100# - All Relays Off
	101# - All Relays On
	102# - All Relays Momentary

	999# - Relay Test Procedure

	# - Deactivate Relay Module

Upon activating the module and if configured, it will prompt the user for a pass code (pin number) and if they do not enter it correctly after the defined number of attempts it will automatically deactivate the module. If it is not defined, then it will go straight into waiting for commands. This gives the ability to lock unwanted users from operating the relays. 

I still have a little more refinement to the TCL code and then I have to create my code for PHP to give control from the web GUI and be able to define the relay gpio pins and other settings like passcode, active high/low, option to turn off all relays when module is deactivated either by timeout or # command.

It’s pretty cool so far. This will be a nice addition to ORP.
