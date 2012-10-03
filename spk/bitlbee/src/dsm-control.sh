#!/bin/sh

# Package
PACKAGE="bitlbee"
DNAME="BitlBee"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/sbin:/usr/local/bin:/bin:/usr/bin:/usr/syno/bin"
RUNAS="bitlbee"
BITLBEE="${INSTALL_DIR}/sbin/bitlbee"
CFG_FILE="${INSTALL_DIR}/var/bitlbee.conf"
PID_FILE="${INSTALL_DIR}/var/bitlbee.pid"


start_daemon ()
{
    su - ${RUNAS} -c "${BITLBEE} -c ${CFG_FILE}"
}

stop_daemon ()
{
    kill `cat ${PID_FILE}`
    wait_for_status 1 20
    rm -f ${PID_FILE}
}

daemon_status ()
{
    if [ -f ${PID_FILE} ] && [ -d /proc/`cat ${PID_FILE}` ]; then
        return 0
    fi
    return 1
}

wait_for_status()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && break
        let counter=counter-1
        sleep 1
    done
}


case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
            exit 0
        else
            echo Starting ${DNAME} ...
            start_daemon
            exit $?
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
            exit $?
        else
            echo ${DNAME} is not running
            exit 0
        fi
        ;;
    restart)
        stop_daemon
        start_daemon
        exit $?
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    *)
        exit 1
        ;;
esac
