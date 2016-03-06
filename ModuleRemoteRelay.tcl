###############################################################################
#
# RemoteRelay module implementation by F8ASB  (F8ASB.COM)
# Activating RemoteRelay Module 9#
# Remote 4 relays on Pin 20,21,22,23 of the Raspberry
# 3 choices:
# OFF = 0  ON = 1 PULSE 100ms = 2
# For example: 201#  -> put ON Relay K1
#               20 (gpio from relay) + choice  
###############################################################################


#
# This is the namespace in which all functions and variables below will exist.
# The name must match the configuration variable "NAME" in the
# [ModulePropagationMonitor] section in the configuration file. The name may
# be changed but it must be changed in both places.
#
namespace eval RemoteRelay {
#
# Check if this module is loaded in the current logic core
#
if {![info exists CFG_ID]} {
  return;
}

#
# Extract the module name from the current namespace
#
set module_name [namespace tail [namespace current]]


#
# A convenience function for printing out information prefixed by the
# module name
#
#   msg - The message to print
#
proc printInfo {msg} {
  variable module_name
  puts "$module_name: $msg"
}


#
# A convenience function for calling an event handler
#
#   ev - The event string to execute
#
proc processEvent {ev} {
  variable module_name
  ::processEvent "$module_name" "$ev"
}



#
# Executed when this module is being activated
#
proc activateInit {} {
  printInfo "Module activated"
  
}


#
# Executed when this module is being deactivated.
#
proc deactivateCleanup {} {
  printInfo "Module deactivated"

}


#
# Executed when a DTMF digit (0-9, A-F, *, #) is received
#
#   char - The received DTMF digit
#   duration - The duration of the received DTMF digit
#
proc dtmfDigitReceived {char duration} {
  #printInfo "DTMF digit $char received with duration $duration milliseconds"

}


#
# Executed when a DTMF command is received
#
#   cmd - The received DTMF command
#
proc dtmfCmdReceived {cmd} {
  printInfo "DTMF command received: $cmd"


set GPIO_RELAY(1) "20"
set GPIO_RELAY(3) "17"
set GPIO_RELAY(4) "23"


	# Split into command into sub digits (Relay & State)
	set digits [split $cmd {}]
	
	# Assign digits to variables
	lassign $digits \
	     relayNum relayState

	if {[info exists GPIO_RELAY($relayNum)]} {
		if {$relayState == "0"} {
			### RELAY OFF ###
			printInfo "Relay $relayNum OFF (GPIO: $GPIO_RELAY($relayNum))"
			playMsg "relay$relayNum";
			playMsg "off";
			exec echo 0 > /sys/class/gpio/gpio$GPIO_RELAY($relayNum)/value &
	
		} elseif {$relayState == "1"} {
			### RELAY ON ###
			printInfo "Relay $relayNum ON (GPIO: $GPIO_RELAY($relayNum))"
			playMsg "relay$relayNum";
			playMsg "on";
			exec echo 1 > /sys/class/gpio/gpio$GPIO_RELAY($relayNum)/value &
	
		} elseif {$relayState == "2"} {
			### RELAY MOMENTARY ###
			printInfo "Relay $relayNum Momentary (GPIO: $GPIO_RELAY($relayNum))"
			playMsg "relay$relayNum";
			playMsg "momentary";
			exec echo 1 > /sys/class/gpio/gpio$GPIO_RELAY($relayNum)/value &
			after 1000
			exec echo 0 > /sys/class/gpio/gpio$GPIO_RELAY($relayNum)/value &
			
		} else {
			processEvent "unknown_command $cmd"
		}

	} elseif {$cmd == ""} {
		deactivateModule
	} else {
		processEvent "unknown_command $cmd"
	}
	
}


#
# Executed when a DTMF command is received in idle mode. That is, a command is
# received when this module has not been activated first.
#
#   cmd - The received DTMF command
#
proc dtmfCmdReceivedWhenIdle {cmd} {
  printInfo "DTMF command received when idle: $cmd"
  
}


#
# Executed when the squelch open or close.
#
#   is_open - Set to 1 if the squelch is open otherwise it's set to 0
#
proc squelchOpen {is_open} {
  if {$is_open} {set str "OPEN"} else { set str "CLOSED"}
  printInfo "The squelch is $str"
  
}


#
# Executed when all announcement messages has been played.
# Note that this function also may be called even if it wasn't this module
# that initiated the message playing.
#
proc allMsgsWritten {} {
  #printInfo "Test allMsgsWritten called..."
}



# end of namespace
}


#
# This file has not been truncated
#
