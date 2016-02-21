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
  printInfo "DTMF digit $char received with duration $duration milliseconds"

}


#
# Executed when a DTMF command is received
#
#   cmd - The received DTMF command
#
proc dtmfCmdReceived {cmd} {
  printInfo "DTMF command received: $cmd"

# ON command 201 211 221 231
  if {$cmd == "11"} {
    printInfo "Relay 1 ON"
    playMsg "relay1";
    playMsg "on";
    #puts "Executing external command"
    #exec gpio -g write 20 1 &

  } elseif {$cmd == "21"} {
    printInfo "Relay 2 ON"
    playMsg "relay2";
    playMsg "on";
    puts "Executing external command"
    exec gpio -g write 21 1 &

  } elseif {$cmd == "31"} {
    printInfo "Relay 3 ON"
    playMsg "relay3";
    playMsg "on";
    puts "Executing external command"
    exec gpio -g write 22 1 &

} elseif {$cmd == "41"} {
    printInfo "Relay 4 ON"
    playMsg "relay4";
    playMsg "on";
    puts "Executing external command"
    exec gpio -g write 23 1 &

#OFF command 200 210 220 230
} elseif {$cmd == "10"} {
    printInfo "Relay 1 OFF"
    playMsg "relay1";
    playMsg "off";
    puts "Executing external command"
    exec gpio -g write 20 0 &

  } elseif {$cmd == "20"} {
    printInfo "Relay 2 OFF"
    playMsg "relay2";
    playMsg "off";
    puts "Executing external command"
    exec gpio -g write 21 0 &

  } elseif {$cmd == "30"} {
    printInfo "Relay 3 OFF"
    playMsg "relay3";
    playMsg "off";
    puts "Executing external command"
    exec gpio -g write 22 0 &

  } elseif {$cmd == "40"} {
    printInfo "Relay 4 OFF"
    playMsg "relay4";
    playMsg "off";
    puts "Executing external command"
    exec gpio -g write 23 0 &

# PULSE command 202 212 222 232
  } elseif {$cmd == "12"} {
    printInfo "Relay 1 Momentary"
    playMsg "relay1";
    playMsg "momentary";
    puts "Executing external command"
    exec gpio -g write 20 1 &
    after 100
    exec gpio -g write 20 0 &

  } elseif {$cmd == "22"} {
    printInfo "Relay 2 Momentary"
    playMsg "relay2";
    playMsg "momentary";
    puts "Executing external command"
    exec gpio -g write 21 1 &
    after 100
    exec gpio -g write 21 0 &

  } elseif {$cmd == "32"} {
    printInfo "Relay 3 Momentary"
    playMsg "relay3";
    playMsg "momentary";
    puts "Executing external command"
    exec gpio -g write 22 1 &
    after 100
    exec gpio -g write 22 0 &

  } elseif {$cmd == "42"} {
    printInfo "Relay 4 Momentary"
    playMsg "relay4";
    playMsg "momentary";
    puts "Executing external command"
    exec gpio -g write 23 1 &
    after 100
    exec gpio -g write 23 0 &

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
  printInfo "Test allMsgsWritten called..."
  
}



# end of namespace
}


#
# This file has not been truncated
#
