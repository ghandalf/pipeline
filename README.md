# README

Main container, of my CI/CD Pipeline base on Alpine. This project goal is to provide containers linked which created our Pipeline.

## This repository

 *pipeline* Entry point of the project, On Premise or Cloud deployment<br>
 *stack*: Sub project with docker container
```bash
pipeline/
├── INFO.BFKP
├── README.md
└── stack
    ├── config
    ├── docker-compose-application.yml
    ├── docker-compose.yml
    ├── README.md
    ├── resources
    └── service.sh
```

### Set up Docker installation

Docker will be used instead of multiple VMs.

```bash
1. Log as super user in Centos 7 guest
2. sudo yum install -y yum-utils device-mapper-persistent-data lvm2 bind-utils bridge-utils
3. sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
4. sudo yum install -y docker-ce
5. sudo usermod -aG docker $(whoami) // Add power user to docker group created by the installation above.
6. sudo systemctl enable docker.service // Start docker at boot time
7. sudo sustemctl start docker.service or sudo service docker start
8. sudo yum install -y epel-release
9. sudo yum install -y python-pip // Dependencies
10. sudo pip install docker-compose // Python installator
11. sudo yum upgrade python* // Will upgrade python-perf libraries in Python 8.1.2
12. docker-compose -version // check if we can run docker-compose
13. sudo yum clean all
```

### Important task

Increase the map count for docker. Elasticsearch uses a mmapfs directory to stores his indices.<br>
CentOs or RedHat limits the mmap count to solve this problem and respect the standard for sysctl service.<br>
We need to create a new file under /etc/sysctl.d directory as root that we will name docker.conf.<br>
Then insert this line in the file vm.max_map_count = 262144. This will set this value permanently.


### Set up Svn and Git client on the server to retrieve ghandalf-pipeline project

The pipeline project contains the stack [Gitlab, Jenkins, SonarQube and Nexus]. We also have the Application to experiment deployement process.

```bash
1. Log as super user
2. sudo vi /etc/yum.repos.d/Wandisco-svn.repo
    _Copy this text in the file_:
    [WandiscoSVN]
    name=Wandisco SVN Repo
    baseurl=http://opensource.wandisco.com/centos/$releasever/svn-1.8/RPMS/$basearch/
    enabled=1
    gpgcheck=0
3. save the file by executing this command in the editor: ESC : wq!
4. sudo yum remove subversion // In case we have an old version
5. sudo yum clean all
6. sudo yum install -y subversion
7. svn --version // check the installation
8. sudo vi /etc/yum.repos.d/Wandisco-git.repo
    -Copy this text in the file_:
    [WandiscoGit]
    name=Wandisco GIT Repository
    baseurl=http://opensource.wandisco.com/centos/7/git/$basearch/
    enabled=1
    gpgcheck=1
    gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
9. save the file by executing this command in the editor: ESC : wq!
10. sudo yum remove git // In case we have an old version
11. sudo yum clean all
12. sudo yum install -y git
13. git --version // check the installation
```

### Retrieve pipeline project and the services

This project we use to generate and deploy on this server all the stack. To execute those commands you will need to activate your VPN connection to Rackspace in your Host machine (Your Windows machine).

```bash
1. Log as super user
2. sudo vi /etc/hosts

3. save the file by executing this command in the editor: ESC : wq!
4. mkdir -p workspace/ghandalf/pipeline // Create a workspace in your account
5. cd workspace/ghandalf // move under the workspace/ghandalf directory
6. 
9. Make sure that in docker-compose.yml the services you need are uncommented.
10. ./service.sh build jenkins // Remember you must be in docker group
11. docker images 
     You should see something like:
     REPOSITORY             TAG                 IMAGE ID        CREATED             SIZE
     ghandalf/jenkins     0.0.1-SNAPSHOT      8eef010d326d    About a minute ago  2.96GB
     ghandalf/jenkins     latest              8eef010d326d    About a minute ago  2.96GB
     centos               latest              1e1148e4cc2c    7 weeks ago         202MB
12. ./service.sh build nexus
13. docker images
     You should see something like: // Don\'t worry the Snapshot is a pointer to latest
     REPOSITORY             TAG                 IMAGE ID        CREATED             SIZE
     ghandalf/jenkins     0.0.1-SNAPSHOT      8eef010d326d    About a minute ago  2.96GB
     ghandalf/jenkins     latest              8eef010d326d    About a minute ago  2.96GB
     ghandalf/nexus       0.0.1-SNAPSHOT      8eef010d326d    About a minute ago  2.96GB
     ghandalf/nexus       latest              8eef010d326d    About a minute ago  2.96GB
     centos               latest              1e1148e4cc2c    7 weeks ago         202MB
```

### Startup all containers

The container must be build and deploy locally. We will have to provice a hub to keep those containers versions.

./service.sh start

Keep an eye on the stack trace it is where you will be able to retrieve the password for Jenkins.
You may have the well know problem that have Jenkins, white screen after the first login or after the first configuration. To solve it stop the stack and restart it.

### Deploy application and configuration

To do this part, we need to connect to the docker host and create a hidden directory

```bash
    1. log on the Virtual Machine: 999726-cicdsrv1.ghandalf.com
    2. go under ghandalf-pipeline/stack
    3. chmod 750 deploy.sh
    2. Execute the following lines:
       a) sudo mkdir -p /usr/local/hidden/dev
       b) sudo mkdir -p /usr/local/hidden/qa
       c) sudo mkdir -p /usr/local/hidden/stage
    3. Create secret files
       a) sudo touch /usr/local/hidden/dev/.service
       b) sudo touch /usr/local/hidden/dev/.application
       c) sudo touch /usr/local/hidden/qa/.service
       d) sudo touch /usr/local/hidden/qa/.application
       e) sudo touch /usr/local/hidden/stage/.service
       f) sudo touch /usr/local/hidden/stage/.application
    4. Edit .service as sudo and insert values, here is an example
        ghandalf_soap_wsdl_url=https://webd4-bp-div.ghandalf.com/24x7/wsghandalfcom/wsghandalfcom.asmx?wsdl
        ghandalf_soap_security_password=DEV-HeyIneedApasswordHereAndIdontWantToSeeIt
        ghandalf_api_auth_password=DEV-OnceAgainPasswordWillBeFindHaveAgoodDay
        transunion_api_auth_password=DEV-TransunionPassword
        google_geo_api_key=DEV-@!~!$Fd45%$dxSon#!+=0_-_#
        mitek_api_client_secret=DEV-NeedThisSecret

    5) Protect hidden directories and files
       a) sudo chown -R root:docker /usr/local/hidden
       b) sudo chmod -R 0450 /usr/local/hidden
```

### Install Cisco AnyConnect Client to reach rackspace

1. Log as super user
2. Install java first
    sudo mkdir -p /usr/share/java
    sudo yum install -y wget
    sudo wget --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz \
    -P /usr/share/java
    sudo tar xzf /usr/share/java/jdk-8*.tar.gz -C /usr/share/java/
    sudo mv /usr/share/java/jdk1.* /usr/share/java/jdk1.8
    sudo echo "export JAVA_HOME=/usr/share/jave/jdk1.8" > java.sh
    source java.sh
    sudo echo "export PATH=${JAVA_HOME}/bin:${PATH}" >> java.sh
    sudo mv java.sh /etc/profile.d/
    sudo chmod 0644 /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
3. Install vpnc client
    sudo yum-config-manager repos --enable rhel-7-server-optional-rpms
    sudo yum install -y vpnc
    




3. Install Cisco AnyConnect Client - We may need to provide username/password to access Cisco Download instead of this third party
    sudo mkdir -p /usr/share/cisco
    sudo wget https://www.itechtics.com/?dl_id=15 -P /usr/share/cisco/
    sudo mv /usr/share/cisco/index* /usr/share/cisco/anyconnect-linux64-4.5.03040-predeploy-k9.tar.gz
    sudo tar xzf /usr/share/cisco/anyconnect* -C /usr/share/cisco/

2. sudo yum install pangox-compat pangox-compat-devel

2. sudo yum install -y openvpn easy-rsa
3. sudo cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn/ // Copy template
4. sudo chown root:openvpn /etc/openvpn/server.conf
5. sudo vi /etc/openvpn/server.conf // We may need to change the DNS access
    push "dhcp-option DNS 8.8.8.8"
    push "dhcp-option DNS 8.8.4.4"
6. sudo mkdir -p /etc/openvpn/easy-rsa/keys
7. sudo cp -rf /usr/share/easy-rsa/3.0.3/* /etc/openvpn/easy-rsa/
8. sudo chown -R root:openvpn /etc/openvpn/
9. sudo vi /etc/openvpn/easy-rsa/vars

### Installing diagnostic tools on guest

1. Log as super user
2. sudo yum install epel-release // Already installed
3. sudo 

### Contribution guidelines

* Code review
* Other guidelines

### Technical advice

* Use https://cloud.google.com/knative/, could be very nice to have.

### Resources

* Repo owner: Francis Ouellet, <fouellet@dminc.com>
* Community: ghandalf team - Internal project only.
