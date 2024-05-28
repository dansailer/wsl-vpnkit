#!/bin/sh
 
LOCK_FILE="/tmp/wsl-vpnkit.lock"
START_SCRIPT="/app/wsl-vpnkit"
 
cleanup() {
    rm -f "${LOCK_FILE}"
    echo "${LOCK_FILE} removed"
    exit 0
}
 
trap cleanup EXIT INT TERM
 
while true; do
    if [ -e "${LOCK_FILE}" ]; then
        if pgrep -x "wsl-gvproxy.exe" > /dev/null; then
            sleep 10s
        else
            echo "Lock file exists, but application is not running. Removing stale lock file."
            rm -f "${LOCK_FILE}"
        fi
    else
        echo "Starting wsl-vpnkit ..."
        touch "${LOCK_FILE}"
        ${START_SCRIPT}
        cleanup
    fi
done