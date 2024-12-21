#!/bin/bash

# Parámetros pasados por Nagios
HOSTNAME=$1
SERVICENAME=$2
STATUS=$3
HOSTSTATE=$4
IP=$5
TYPE=$6

#LOG FILE
LOGFILE="/usr/local/nagios/var/icexs_event_handler.log"

# Obtener la hora actual
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

echo $timestamp $HOSTNAME $SERVICENAME $STATUS $HOSTSTATE $IP $TYPE >> $LOGFILE

# Verifica si el estado del servicio es CRITICAL y de tipo HARD
if [ "$STATUS" == "CRITICAL"  ] && [ "$TYPE" == "HARD"  ]   ; then
    # Verifica si el estado del host es OK
    if [ "$HOSTSTATE" == "UP" ]; then
        # Aquí va tu lógica para manejar el estado crítico del servicio
        echo $timestamp "Ejecutando script porque el host ($HOSTNAME) está OK y el servicio ($SERVICENAME) está CRÍTICO" >> $LOGFILE
        echo $timestamp "curl -f -H 'Content-Type: application/json' -XPOST --user ********:***** \-d '{"extra_vars":{"managed_hosts_survey":"$IP"}}' https://ansible.liverpool.com.mx/api/v2/job_templates/663/launch/ --insecure" >> $LOGFILE
        curl -f -H 'Content-Type: application/json' -XPOST --user automation_monitoreo:*M0n1t0r30* \-d "{\"extra_vars\":{\"managed_hosts_survey\":\"$IP\"}}" https://ansible.liverpool.com.mx/api/v2/job_templates/663/launch/ --insecure
    else
        echo $timestamp "El estado del host ($HOSTNAME) no es UP. No se ejecuta el script." >> $LOGFILE
    fi
else
    echo $timestamp "El estado del servicio ($SERVICENAME) no es CRITICAL. No se ejecuta el script." >> $LOGFILE
fi

