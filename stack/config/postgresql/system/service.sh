#!/bin/bash

command=$1

function start() {
    echo -e "Starting SonarQube server...";
    
    # Use to start SonarQube on jdk 8 using our timezone
    java -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York -DSONARQUBE_HOME=${SONARQUBE_HOME}/data -jar ${SONARQUBE_HOME}/bin/sonarqube.war --httpPort=${SONARQUBE_PORT}
}

###
# Gracefull shutdown is manage by docker
##
function stop() {
    echo -e "Stop experimental implementation ...";
    curl http://localhost:${SONARQUBE_PORT}/exit
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac
