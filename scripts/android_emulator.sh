# TODO: kill only the emulators we started
# TODO: trap keeps fireing after process is already closed
# TODO: have to press ctrl+c twice to trigger the trap
# TODO: possible to just write "stopping emulators" when ctrl+c is pressed and close when it actually finishes?
# TODO: logs keep on printing after we have closed
# TODO: make it parallel! Right now I think emulators are started one by one
# TODO: also kill in parallel
#
# Function to start an emulator in headless mode
android_start_emulator() {
  local known_devices=$(adb devices | grep emulator | awk '{print $1}')

  declare -a started_emulators
  declare -A emulator_names

  port=5678

  start_emulator() {
    avd_name=$1
    echo "STARING EMULATOR WITH PROP myemu $avd_name"
    echo "STARING EMULATOR  WITH PROP myemu $avd_name" >> /tmp/emulog
    emulator -avd $avd_name -port $port -no-window &
    emulator_names["emulator-$port"]="$avd_name"
    port=$((port + 2))
    local pid=$!
    # Wait for the emulator to be listed by adb devices
    while true; do
      serial=$(adb devices | grep emulator | grep -v offline | awk '{print $1}' | tail -n 1)
      if [ -n "$serial" ]; then
        started_emulators+=("$serial")
        break
      fi
      sleep 1
    done
  }

  connect_scrcpy() {
    serial=$1
    name=$2

    while true; do
      echo "Trying to connect to $serial ($name) with scrcpy..."
      echo "Trying to connect to $serial ($name) with scrcpy..." >> /tmp/emulog
      scrcpy -s $serial --window-title "$name" && break
      # Wait for 2 seconds before retrying
      sleep 2
    done
  }

  monitor_emulators() {
    local known_devices="$1"
    echo "MONITOR EMULATORS: known_devices = $known_devices"
    echo "MONITOR EMULATORS: known_devices = $known_devices" >> /tmp/emulog
    while true; do
      current_devices=$(adb devices | grep emulator | awk '{print $1}')
      for device in $current_devices; do
        if ! echo "$known_devices" | grep -q "$device"; then
          echo "New emulator detected: $device"
          echo "New emulator detected: $device" >> /tmp/emulog
          connect_scrcpy $device ${emulator_names[$device]} &
          known_devices="$known_devices $device"
        fi
      done
      # Wait for 2 seconds before checking again
      sleep 2
    done
  }

  stop_emulators() {
    echo "SIGING TRAPPED Stopping emulators..."
    echo "SIGINT TRAPPED Stopping emulators..." >> /tmp/emulog
    android_kill_all_emulators
    # echo "Stopping emulators..."
    # echo "Stopping emulators..." >> /tmp/emulog
    # for device in "${started_emulators[@]}"; do
    #   echo "Stopping scrcpy scrcpy -s $device"
    #   echo "Stopping scrcpy scrcpy -s $device" >> /tmp/emulog
    #   pkill -f "srccpy -s $device"
    #   echo "Stopping emulator $device"
    #   echo "Stopping emulator $device" >> /tmp/emulog
    #   adb -s $device emu kill
    # done
  }

  # Trap Ctrl-C (SIGINT) and stop emulators
  trap stop_emulators SIGINT

  # If no arguments are provided, use emulator -list-avds
  if [ "$#" -eq 0 ]; then
    AVDS=$(emulator -list-avds)
  else
    AVDS="$@"
  fi

  # Start each emulator in headless mode
  for avd in $AVDS; do
    start_emulator "$avd"
  done

  # Start monitoring for new emulators
  monitor_emulators "$known_devices"
}


android_kill_all_emulators() {
  echo "killing all android emulators"
  echo "killing all android emulators" >> /tmp/emulog
  local emulators=$(adb devices | grep emulator | awk '{print $1}')
  pkill -f "scrcpy -s emulator-*"
  for device in $emulators; do
    echo "Killing $device"
    echo "Killing $device" >> /tmp/emulog
    adb -s "$device" emu kill
  done;
}

# Export the function
export -f android_start_emulator
export -f android_kill_all_emulators

