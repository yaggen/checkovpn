

#!/bin/bash
LOG="/var/log/ovpn.log"
DATE=`date "+%Y-%m-%d %H:%M:%S"`

#Kollar med ping om OVPN har anslutning, startar annars om.
checkcmd=`pgrep openvpn`
pubip=`curl https://www.ovpn.com/v2/api/client/ptr 2>/dev/null | cut -d '"' -f 6| awk '{print $1}'`

if [ $pubip !=  "ValidationException" ]; then
        echo "OVPN is up and running :)"
else
        echo "[$DATE] Restarting daemon" >> $LOG
        kill -3 $checkcmd 2>/dev/null
        sleep 2
        openvpn --config /etc/openvpn/ovpn.conf --daemon
        sleep 3
        exec $0
fi


ping -c 1 8.8.8.8 &>/dev/null
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo "[$DATE] Connection lost sending SIGQUIT to OVPN with PID $checkcmd" >> $LOG
    kill -3 $checkcmd
    sleep 2
    echo "[$DATE] Service stopped, restarting OVPN" >> $LOG
    openvpn --config /etc/openvpn/ovpn.conf --daemon
fi




