#!/bin/bash

command=$1

function start() {
    echo -e "Starting Jenkins server...";

    # Use to start Jenkins on jdk 8 using our timezone
    java -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York -DJENKINS_HOME=${JENKINS_HOME}/data -jar ${JENKINS_HOME}/bin/jenkins.war --httpPort=${JENKINS_PORT}
}

###
# Gracefull shutdown is manage by docker
##
function stop() {
    echo -e "Stop experimental implementation ...";
    curl http://localhost:${JENKINS_PORT}/exit
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac
