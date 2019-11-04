#!/bin/bash

###
## Use to work with current docker configuration
##
## Author: Francis Ouellet <fouellet@dminc.com>
###

## Script command and arguments
# set -x
command=$1
args=($2 $3 $4 $5 $6 $7 $8 $9)

###
# Load properties files
##
function loadResources() {
	echo -e "\n\tLoading resources...";

	if [ -f .env ]; then
		source .env;
	else
		echo -e "${n1t}You need to provide .env file under root ./ directory.";
		usage;
	fi
	if [ -d resources ]; then
		for resource in resources/*.properties; do
			source ${resource};
		done
	else
		# No colors here, the file failed to be sourced
		echo -e "\n\tThe resources directory doen't exist.\n";
		usage;
	fi
}

###
# Build container
# The prefix must be the company name or a project name
##
function build() {
	local prefix=$1;
	local name=$2;
	
	echo -e "Result: ${prefix} ${#prefix}"

	if [  ${#prefix} -le 0 ]; then
		echo -e "${n1t}${Red}You need to provide the prefix. example: ghandalf.${Color_Off}";
		usage;
	fi
	if [  ${#name} -le 0 ]; then
		echo -e "${n1t}${Red}You need to provide the name of the container.${Color_Off}";
		usage;
	fi
	
	docker build -f ./config/${name}/Dockerfile -t ${prefix}/${name}:${CONTAINERS_VERSION} . 
}

###
# Will start the services define in the compose file provided.
##
function start() {
	stop;
	docker-compose up;
	# Run in background
	#docker-compose up -d;
}

###
# Will stop running services define in the given compose file.
##
function stop() {
	docker-compose down;
}

###
# Remove all containers, networks and force leaving the swarm due to manager container.
#
##
function clean() {

	echo -e "${tab}${Red}Are you sure you want to continue y|n?${Color_Off}.";
	read answer

	case $answer in
		"y"|"Y") 
			echo -e "${tab}${Red}Stopping containers `docker stop $(docker ps -aq)`${Color_Off}.";
			echo -e "${tab}${Red}Removing containers `docker rm $(docker ps -aq)`${Color_Off}.";
			echo -e "${tab}${Red}Removing dangling (tag none) containers `docker rmi $(docker images -f 'dangling=true' -q)`${Color_Off}.";
			#echo -e "${tab}${BRed}Removing images: `docker rmi $(docker images -aq)`${Color_Off}.";

			#local result=`docker network ls --filter 'name=${NETWORK_NAME}' | grep ${NETWORK_NAME} | awk {'printf $2'}`;
			#for network in "${networks[@]}"; do
			#	echo -e "${tab}${Red}Removing network: ${network} ${Color_Off}.";
			#	docker network rm ${network};
			#done
			;;
		"n"|"N") 
			exit ;;
		*) 
			echo -e "${n1t}${BRed}You must answer y or n${Color_Off}.";
			usage ;;
	esac

	echo -e "\n";
}

###
# Provide information on the services running.
##
function info() {
	local compose_file=$1

	if [ ! -z ${compose_file} ]; then
		if [ -f ${compose_file} ]; then
			echo -e "${n1t}${Yellow}Compose file validation:${Color_Off}[${Green}`docker-compose config`${Color_Off}].";
			echo -e "${n1t}${Yellow}Images:${Color_Off}[${Green}`docker images`${Color_Off}].";
			echo -e "${n1t}${Yellow}Running containers:${Color_Off}[${Green}`docker ps`${Color_Off}].";
			echo -e "${n1t}${Yellow}All containers:${Color_Off}[${Green}`docker ps -a`${Color_Off}].";
			echo -e "${n1t}${Yellow}List networks:${Color_Off}[${Green}`docker network ls`${Color_Off}].";
			echo -e "${n1t}${Yellow}List service:${Color_Off}[${Green}`docker service ls`${Color_Off}].";
			
			for container in `docker ps -a --format {{.Names}}`; do
				echo -e "${tab}${Yellow}$container${Color_Off} ip: [${Green}`docker container port $container`${Color_Off}]";
				echo -e "${tab}${Yellow}$container${Color_Off} log: [${Green}`docker inspect --format {{.LogPath}} $container`${Color_Off}]";
			done

			echo -e "${n1t}${Yellow}In case you need to install some tools in a container execute:${Color_Off}";
			echo -e "${tab}${tab}${Green}docker exec -u 0 -it <container name> bash -c \"<command>\"${Color_Off}";
			echo -e "${tab}${Yellow}To see the log of a container execute:${Color_Off}";
			echo -e "${tab}${tab}${Green}docker logs -f <containername>${Color_Off}\n";
		else
			echo -e "${n1t}${BRed}The compose file [${compose_file}] provided didn't exists${Color_Off}.";
			usage;
		fi
	else
		echo -e "${n1t}${BRed}Please, you need to provide the compose file${Color_Off}.";
		usage;
	fi
}

###
# Give the status of the current stack. 
# The presentation order will be:
# 		Gitlab, Jenkins, Nexus
##
function status() {
	# Check if we are in the host (Centos or Redhat)
	if [ "$(hostname)"=="devops.ghandalf.com" ]; then
		echo -e "${tab}${Green}Checking for Gitlab: $(curl -s -o /dev/null -w "%{http_code}\n" http://devops.ghandalf.com:32180) ${Color_Off}.";
		echo -e "${tab}${Green}Checking for Jenkins: $(curl -s -o /dev/null -w "%{http_code}\n" http://devops.ghandalf.com:32280) ${Color_Off}.";
		echo -e "${tab}${Green}Checking for Nexus: $(curl -s -o /dev/null -w "%{http_code}\n" http://devops.ghandalf.com:32380) ${Color_Off}.";
	else 
		echo -e "${tab}${Green}Checking for Gitlab: $(curl -s -o /dev/null -w "%{http_code}\n" http://gitlab:32180) ${Color_Off}.";
		echo -e "${tab}${Green}Checking for Jenkins: $(curl -s -o /dev/null -w "%{http_code}\n" http://jenkins:32280) ${Color_Off}.";
		echo -e "${tab}${Green}Checking for Nexus: $(curl -s -o /dev/null -w "%{http_code}\n" http://nexus:32380) ${Color_Off}.";
	fi
}

###
# Will connect to a running container
##
function connect() {
	local containerName=${args[0]}
	local type=${args[1]}

	if [ ! -z ${containerName} ]; then
			case ${type} in
				"root") 
					docker exec -u 0 -it ${containerName} /bin/bash;
					;;
				"user")
					docker exec -it ${containerName} /bin/bash;
					;;
				*)
					echo -e "${n1t}${BRed}Please, you need to provide the type of the connection root|user${Color_Off}.";
					usage;
					;;
			esac
	else
		echo -e "${n1t}${BRed}Please, you need to provide the name of the container${Color_Off}.";
		usage;
	fi
}

function unixize() {
	local path=$1;
	
	for file in ${path}/*; do
		if [ -f ${file} ]; then
			dos2unix ${file} 2>/dev/null;
		else
			if [[ $(ls -A ${file}) ]]; then
				unixize ${file};
			fi
		fi
	done
		#	echo "file: $file";
}

###
# Define how to use this script
##
function usage() {
  echo -e "${n1t}Usage:";
  	echo -e "${tab}${Cyan}$0 ${Yellow}-b|b|build <prefix> <name>		${Green}Build the container using prefix in (ghandalf) and name in (dev, qa, stage)${Color_Off}.";
	echo -e "${tab}${Yellow}			where ${Cyan}prefix	${Yellow}is the company or project name${Color_Off}.";
	echo -e "${tab}${Yellow}			where ${Cyan}name	${Yellow}must be in this list:(gitlab, jenkins, nexus)${Color_Off}.";
	echo -e "${tab}${Cyan}$0 ${Yellow}start ${Green}Start the services define in the compose file provided${Color_Off}.";
	echo -e "${tab}${Cyan}$0 ${Yellow}status ${Green}Status of the running containers${Color_Off}.";
	echo -e "${tab}${Cyan}$0 ${Yellow}stop ${Green}Stop the services define in the compose file provided${Color_Off}.";
	echo -e "${nl}";
	echo -e "${tab}${Cyan}$0 ${Yellow}connect <name> <type>	${tab}${Green}Connect in bash mode to the given user type and container name${Color_Off}.";
	echo -e "${tab}${Yellow}			where ${Cyan}name	${Yellow}must be in this list:(gitlab, jenkins, nexus)${Color_Off}.";
	echo -e "${tab}${Yellow}			where ${Cyan}type	${Yellow}must be root or user${Color_Off}.";
	
	echo -e "${nl}";
	echo -e "${tab}${Cyan}$0 ${Yellow}-i|i <docker-compose-file>		${Green}Give minimal info on the containers for this stack, link to the compose file provided${Color_Off}.";
	
	echo -e "${tab}${Cyan}$0 ${On_IPurple}clean				${Green}Stop running and remove containers and remove networks${Color_Off}.";
	echo -e "${n1t}${Cyan}${tabs4} ${On_IPurple}		ATTENTION: using clean arguments could lead to data lost${Color_Off}.";
	echo -e "${nl}";
	exit 0;
}

loadResources;
case ${command} in
	-b|b|build)
		prefix=$2; name=$3;
		build ${prefix} ${name}; ;;
	-i|i)
		info $args ;;
	start)
		start $args ;;
	stop)
		stop $args ;;
	status)
		status $args ;;
	connect)
		connect $args ;;
	clean)
		clean $args ;;
	unix) unixize $2; ;;
  *) 
		usage ;;
esac
