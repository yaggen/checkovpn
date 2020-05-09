#!/bin/bash
LOG="/var/log/ovpn.log"
DATE=`date "+%Y-%m-%d %H:%M:%S"`


#Kollar med ping om OVPN har anslutning, startar annars om.
checkcmd=`ps aux | grep "openvpn --config" | grep -v "grep" | awk '{print $2}'`
pubip=`curl https://www.ovpn.com/v2/api/client/ptr 2>/dev/null | cut -d '"' -f 6| awk '{print $1}'`

ping -c 1 8.8.8.8 &>/dev/null
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo "[$DATE] Connection lost sending SIGQUIT to OVPN with PID $checkcmd" >> $LOG
    kill -3 $checkcmd
    sleep 2
    echo "[$DATE] Service stopped, restarting OVPN" >> $LOG
    openvpn --config /etc/openvpn/ovpn.conf --daemon
    echo "[$DATE] Checking public IP" >> $LOG
    if [ $pubip != "MY-IP-HERE" ]; then
        exec $0
    else
        echo "[$DATE] Connection reestablished, quitting" >> $LOG
    fi
else
    echo "OVPN up and running :)"
fi
