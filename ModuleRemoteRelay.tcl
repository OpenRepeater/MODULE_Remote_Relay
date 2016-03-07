###############################################################################
#  OpenRepeater RemoteRelay Module
#  Coded by Aaron Crawford (N3MBH) & Juan Hagen (F8ASB)
#  For DTMF Control of up to 8 relay via GPIO pins as defined in config file.
#
#  General Usage (3 choices):
#  OFF = 0 | ON = 1 | MOMENTARY = 2
#  Example: 21#  -> Turns ON Relay 2 (if defined)
#
#  Visit the project at OpenRepeater.com
###############################################################################


# Start of namespace
namespace eval RemoteRelay {
	
	# Check if this module is loaded in the current logic core
	if {![info exists CFG_ID]} {
		return;
	}
	

	# Extract the module name from the current namespace
	set module_name [namespace tail [namespace current]]
	

	# A convenience function for printing out information prefixed by the module name
	proc printInfo {msg} {
		variable module_name
		puts "$module_name: $msg"
	}
	

	# A convenience function for calling an event handler
	proc processEvent {ev} {
		variable module_name
		::processEvent "$module_name" "$ev"
	}
	

	# Executed when this module is being activated
	proc activateInit {} {
		variable GPIO_RELAY
		variable MOMENTARY_DELAY
		variable ACCESS_PIN
		variable ACCESS_PIN_REQ
		variable ACCESS_GRANTED
		variable ACCESS_ATTEMPTS_ALLOWED
		variable ACCESS_ATTEMPTS_ATTEMPTED
		

		set GPIO_RELAY(1) "20"
		set GPIO_RELAY(3) "17"
		set GPIO_RELAY(4) "23"
	
		# delay value in milliseconds
		set MOMENTARY_DELAY "3000"

		set ACCESS_PIN "1234"
		set ACCESS_PIN_REQ 1
		set ACCESS_GRANTED 0
		set ACCESS_ATTEMPTS_ALLOWED 3
		set ACCESS_ATTEMPTS_ATTEMPTED 0

		printInfo "Module activated"

		if {$ACCESS_PIN_REQ == "1"} {
			printInfo "PLEASE ENTER YOUR PIN FOLLOWED BY THE POUND SIGN --------------------"
		}
	}
	

	# Executed when this module is being deactivated.
	proc deactivateCleanup {} {
		printInfo "Module deactivated"
	}
	

	# Executed when a DTMF digit (0-9, A-F, *, #) is received
	proc dtmfDigitReceived {char duration} {
		#printInfo "DTMF digit $char received with duration $duration milliseconds"
	}

	
	# Executed when a DTMF command is received
	proc changeRelayState {cmd} {
		printInfo "DTMF command received: $cmd"
	
		variable GPIO_RELAY
		variable MOMENTARY_DELAY
			
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
				after $MOMENTARY_DELAY
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

	proc dtmfCmdReceived {cmd} {
		variable ACCESS_PIN
		variable ACCESS_PIN_REQ
		variable ACCESS_GRANTED
		variable ACCESS_ATTEMPTS_ALLOWED
		variable ACCESS_ATTEMPTS_ATTEMPTED		

		if {$ACCESS_PIN_REQ == 1} {
			# Pin Required
			if {$ACCESS_GRANTED == 1} {
				# Access Granted - Pass commands to relay control
				changeRelayState $cmd
			} else {
				# Access Not Granted Yet, Process Pin
				if {$cmd == $ACCESS_PIN} {
					printInfo "ACCESS GRANTED --------------------"
					set ACCESS_GRANTED 1
				} elseif {$cmd == ""} {
					# If only pound sign is entered, deactivate module
					deactivateModule
				} else {
					incr ACCESS_ATTEMPTS_ATTEMPTED
					printInfo "FAILED ACCESS ATTEMPT ($ACCESS_ATTEMPTS_ATTEMPTED/$ACCESS_ATTEMPTS_ALLOWED) --------------------"

					if {$ACCESS_ATTEMPTS_ATTEMPTED < $ACCESS_ATTEMPTS_ALLOWED} {
						printInfo "Please try again!!! --------------------"
					} else {
						printInfo "ACCESS DENIED!!! --------------------"
						deactivateModule
					}
				}					
			}

		} else {
			# No Pin Required - Pass straight on to relay control 
			changeRelayState $cmd
			printInfo "NO PIN --------------------"
		}

	}	
	
	# Executed when a DTMF command is received in idle mode. (Module Inactive)
	proc dtmfCmdReceivedWhenIdle {cmd} {
		printInfo "DTMF command received when idle: $cmd"
	}
	
	
	# Executed when the squelch opened or closed.
	proc squelchOpen {is_open} {
		if {$is_open} {set str "OPEN"} else { set str "CLOSED"}
		printInfo "The squelch is $str"
	}
	

	# Executed when all announcement messages has been played.
	proc allMsgsWritten {} {
		#printInfo "Test allMsgsWritten called..."
	}


# end of namespace
}