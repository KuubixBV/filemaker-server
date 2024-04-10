#!/bin/bash

# Timeout for shutdown in seconds
TIMEOUT=900  # 15 minutes
ELAPSED=0
CHECK_INTERVAL=10

stop_service() {
    systemctl stop "$1"
    echo "Requested stop for $1."
}

wait_for_process_end() {
    local process_name="$1"
    while [ $ELAPSED -lt $TIMEOUT ]; do
        if ! pgrep -f "$process_name" > /dev/null; then
            echo "$process_name has stopped."
            return 0
        fi
        sleep $CHECK_INTERVAL
        ELAPSED=$((ELAPSED + CHECK_INTERVAL))
        echo "Waiting for $process_name to stop... $ELAPSED seconds elapsed."
    done
    echo "Timeout reached, but $process_name did not stop. You might need to force stop it."
}

# Stopping the fmshelper service
stop_service "fmshelper"

# Waiting for the fmshelper process to end
wait_for_process_end "fmshelper"

exit 0