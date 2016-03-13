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
		

		set GPIO_RELAY(1) "26"
		set GPIO_RELAY(2) "19"
		set GPIO_RELAY(3) "13"
		set GPIO_RELAY(4) "6"
	
		# delay value in milliseconds
		set MOMENTARY_DELAY "200"

		set ACCESS_PIN "1234"
		set ACCESS_PIN_REQ 0
		set ACCESS_GRANTED 0
		set ACCESS_ATTEMPTS_ALLOWED 3
		set ACCESS_ATTEMPTS_ATTEMPTED 0

		printInfo "Module activated"

		if {$ACCESS_PIN_REQ == "1"} {
			printInfo "--- PLEASE ENTER YOUR PIN FOLLOWED BY THE POUND SIGN ---"
			playMsg "access-enter-pin";

		} else {
			# No Pin Required but this is the first time the module has been run so play prompt
			playMsg "enter-command";
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

	

	# Returns voice status of all relays
	proc allRelaysStatus {} {
		variable GPIO_RELAY
		printInfo "STATUS OF ALL RELAYS"
		foreach RELAY_NUM [lsort [array name GPIO_RELAY]] {
			set GPIO_NUM $GPIO_RELAY($RELAY_NUM)
			set GPIO_FILE [open "/sys/class/gpio/gpio$GPIO_NUM/value" r]
			set RELAY_STATE [read -nonewline $GPIO_FILE]
			close $GPIO_FILE
			if {$RELAY_STATE == "1"} {
				printInfo "Relay $RELAY_NUM ON"
				playMsg "relay$RELAY_NUM";
				playMsg "on";
				playSilence 700;
			} else {
				printInfo "Relay $RELAY_NUM OFF"
				playMsg "relay$RELAY_NUM";
				playMsg "off";
				playSilence 700;
			}
		}
	}

	# Proceedure to turn off all relays
	proc allRelaysOFF {} {
		variable GPIO_RELAY
		printInfo "TURN ALL RELAYS OFF"
		foreach RELAY_NUM [lsort [array name GPIO_RELAY]] {
			set GPIO_NUM $GPIO_RELAY($RELAY_NUM)
		    printInfo "Relay $RELAY_NUM OFF"
			exec echo 0 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after 100
		}
	}

	# Proceedure to turn on all relays
	proc allRelaysON {} {
		variable GPIO_RELAY
		printInfo "TURN ALL RELAYS ON"
		foreach RELAY_NUM [lsort [array name GPIO_RELAY]] {
			set GPIO_NUM $GPIO_RELAY($RELAY_NUM)
		    printInfo "Relay $RELAY_NUM ON"
			exec echo 1 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after 100
		}
	}

	# Proceedure to turn all relays on momentary
	proc allRelaysMomentary {} {
		variable GPIO_RELAY
		variable MOMENTARY_DELAY
		printInfo "TURN ALL RELAYS MOMENTARY"
		foreach RELAY_NUM [lsort [array name GPIO_RELAY]] {
			set GPIO_NUM $GPIO_RELAY($RELAY_NUM)
		    printInfo "Relay $RELAY_NUM Momentary"
			#Turn off first to reset if already left on.
			exec echo 0 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after $MOMENTARY_DELAY
			exec echo 1 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after $MOMENTARY_DELAY
			exec echo 0 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after 100
		}
	}

	# Proceedure to test all relays
	proc testAllRelays {} {
		variable GPIO_RELAY
		printInfo "RELAY TEST"
			foreach RELAY_NUM [lsort [array name GPIO_RELAY]] {
				set GPIO_NUM $GPIO_RELAY($RELAY_NUM)
		    printInfo "Testing Relay $RELAY_NUM (GPIO $GPIO_NUM)"
			exec echo 1 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after 500
			exec echo 0 > /sys/class/gpio/gpio$GPIO_NUM/value &
			after 500
		}
	}

	# Proceedure to turn off single relay
	proc relayOff {NUM} {
		variable GPIO_RELAY
		printInfo "Relay $NUM OFF (GPIO: $GPIO_RELAY($NUM))"
		playMsg "relay$NUM";
		playMsg "off";
		exec echo 0 > /sys/class/gpio/gpio$GPIO_RELAY($NUM)/value &
	}

	# Proceedure to turn on single relay
	proc relayOn {NUM} {
		variable GPIO_RELAY
		printInfo "Relay $NUM ON (GPIO: $GPIO_RELAY($NUM))"
		playMsg "relay$NUM";
		playMsg "on";
		exec echo 1 > /sys/class/gpio/gpio$GPIO_RELAY($NUM)/value &
	}

	# Proceedure to turn on single relay
	proc relayMomentary {NUM} {
		variable GPIO_RELAY
		variable MOMENTARY_DELAY
		printInfo "Relay $NUM Momentary (GPIO: $GPIO_RELAY($NUM))"
		playMsg "relay$NUM";
		playMsg "momentary";
		#Turn off first to reset if already left on.
		exec echo 0 > /sys/class/gpio/gpio$GPIO_RELAY($NUM)/value &
		after $MOMENTARY_DELAY
		exec echo 1 > /sys/class/gpio/gpio$GPIO_RELAY($NUM)/value &
		after $MOMENTARY_DELAY
		exec echo 0 > /sys/class/gpio/gpio$GPIO_RELAY($NUM)/value &
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
		
		if {$cmd == "0"} {
			allRelaysStatus
			
		} elseif {$cmd == "100"} {
			allRelaysOFF
			
		} elseif {$cmd == "101"} {
			allRelaysON

		} elseif {$cmd == "102"} {
			allRelaysMomentary
			
		} elseif {$cmd == "999"} {
			testAllRelays

		# Process single relay split commands. 1st Digit is relay number, second is relay state.
		} elseif {[info exists GPIO_RELAY($relayNum)]} {
			if {$relayState == "0"} {
				### RELAY OFF ###
				relayOff $relayNum
				
			} elseif {$relayState == "1"} {
				### RELAY ON ###
				relayOn $relayNum
		
			} elseif {$relayState == "2"} {
				### RELAY MOMENTARY ###
				relayMomentary $relayNum
			} else {
				processEvent "unknown_command $cmd"
			}
	
		} elseif {$cmd == ""} {
			deactivateModule
		} else {
			processEvent "unknown_command $cmd"
		}
		
	}

	# Execute when a DTMF Command is received and check for access.
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
					set ACCESS_GRANTED 1
					printInfo "ACCESS GRANTED --------------------"
					playMsg "access-granted";
					playMsg "enter-command";
				} elseif {$cmd == ""} {
					# If only pound sign is entered, deactivate module
					deactivateModule
				} else {
					incr ACCESS_ATTEMPTS_ATTEMPTED
					printInfo "FAILED ACCESS ATTEMPT ($ACCESS_ATTEMPTS_ATTEMPTED/$ACCESS_ATTEMPTS_ALLOWED) --------------------"

					if {$ACCESS_ATTEMPTS_ATTEMPTED < $ACCESS_ATTEMPTS_ALLOWED} {
						printInfo "Please try again!!! --------------------"
						playMsg "access-invalid-pin";
						playMsg "access-try-again";
					} else {
						printInfo "ACCESS DENIED!!! --------------------"
						playMsg "access-denied";
						deactivateModule
					}
				}					
			}

		} else {
			# No Pin Required - Pass straight on to relay control
			changeRelayState $cmd
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