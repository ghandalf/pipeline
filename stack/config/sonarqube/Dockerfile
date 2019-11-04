FROM alpine:latest

LABEL Author="Francis Ouellet <Ouellet.Francis@gmail.com>"
LABEL Description="Base on Alpine"

RUN apk update
RUN apk add tree net-tools wget

# Libraries needed by java
# Thanks to 
#   https://deangerber.com/blog/2018/09/08/minimal-java-server-docker-image/
#   https://hub.docker.com/r/anapsix/alpine-java/dockerfile/
ENV GLIBC_REPO https://github.com/sgerrand/alpine-pkg-glibc
ENV GLIBC_VERSION 2.30-r0
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV LOCALE_PROFILE_FILE /etc/profile.d/locale.sh

RUN echo "export LANG=C.UTF-8" > ${LOCALE_PROFILE_FILE} && \
    echo "export LANGUAGE=en_US:en" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_ALL=en_US.UTF-8" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_ADDRESS=Canada" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_IDENTIFICATION English=locale" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_MEASUREMENT=metric" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_NAME=Mr. Francis Ouellet" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_PAPER US=letter" >> ${LOCALE_PROFILE_FILE} && \
    echo "export LC_TELEPHONE=01" >> ${LOCALE_PROFILE_FILE}
RUN cat ${LOCALE_PROFILE_FILE}
RUN chmod 0644 ${LOCALE_PROFILE_FILE}
RUN apk --update --no-cache add libstdc++ curl ca-certificates java-cacerts bash tar xz && \
    source ${LOCALE_PROFILE_FILE} && \
    cd /tmp && \
    curl -so /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do \
       curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; \
    done && \
    apk add --allow-untrusted /tmp/*.apk && \
    curl -Lso /tmp/libz.tar.xz https://www.archlinux.org/packages/core/x86_64/zlib/download && \
    mkdir -p libz && \
    tar -xf libz.tar.xz -C libz && \
    cp libz/usr/lib/libz.so.* /usr/glibc-compat/lib && \
    rm -v /tmp/*.apk && rm -rf /tmp/glibc-* && rm -rf /tmp/libz.tar.xz && rm -rf /tmp/libz && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

# Java installation    
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 231
ENV JAVA_VERSION_BUILD 11
ENV JAVA_VERSION jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}
ENV JAVA_DIR /usr/share/java
ENV JAVA_HOME ${JAVA_DIR}/${JAVA_VERSION}
ENV JAVA_PACKAGE server-jre
ENV JAVA_PLATFORM linux-x64
ENV JAVA_FILE ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-${JAVA_PLATFORM}.tar.gz
ENV JAVA_PROFILE_FILE /etc/profile.d/java.sh
ENV PATH ${PATH}:${JAVA_HOME}/bin

RUN mkdir -p ${JAVA_DIR}
COPY ./config/common/${JAVA_FILE} ${JAVA_DIR}/
RUN tar -xz -f ${JAVA_DIR}/${JAVA_FILE} -C ${JAVA_DIR}/
RUN echo "export JAVA_HOME=/usr/share/java/jdk1.8.0_231" > ${JAVA_PROFILE_FILE} && \
    echo "export PATH=\${PATH}:\${JAVA_HOME}/bin" >> ${JAVA_PROFILE_FILE} && \
    cat ${JAVA_PROFILE_FILE} && source ${JAVA_PROFILE_FILE}
RUN chmod 0644 ${JAVA_PROFILE_FILE}
RUN rm -rf ${JAVA_DIR}/${JAVA_FILE}
RUN ${JAVA_HOME}/bin/java -version
# Java installation done



# ENV ROOT_DIR /usr/share

# # SonarQube
# ENV SONARQUBE_NAME sonarqube
# ENV SONARQUBE_DIR ${ROOT_DIR}/${SONARQUBE_NAME}
# ENV SONARQUBE_VERSION 7.9
# ENV SONARQUBE_PORT 32680
# ENV APP_USER ${SONARQUBE_NAME}
# ENV APP_GROUP ${SONARQUBE_NAME}
# ENV APP_HOME ${SONARQUBE_HOME}

# # PostgreSQL
# ENV POSTGRESQL_NAME postgresql
# ENV POSTGRESQL_HOME ${ROOT_DIR}/${POSTGRESQL_NAME}
# ENV POSTGRESQL_VERSION 12
# ENV POSTGRESQL_PORT 5432
# RUN /etc/pam.d/postgresql status
#/etc/pam.d/postgresql
#/usr/libexec/initscripts/legacy-actions/postgresql
#/usr/share/doc/postgresql
#/run/postgresql
#RUN systemctl start postgresql
# RUN service postgresql start
# RUN systemctl enable postgresql
# RUN postgresql-setup --initdb --unit postgresql
# Postgres installation# Postgres installation
#RUN mkdir -p ${POSTGRESQL_HOME}
#RUN wget https://ftp.postgresql.org/pub/source/v12.0/postgresql-12.0.tar.gz -P ${POSTGRESQL_HOME}
#RUN tar -xz -f ${POSTGRESQL_HOME}/postgresql-12.0.tar.gz -C ${POSTGRESQL_HOME}
#ENV POSTGRESQL_INSTALL ${POSTGRESQL_HOME}/postgresql-12.0
#RUN cd ${POSTGRESQL_INSTALL} \
#   && ./configure --prefix=${POSTGRESQL_HOME} \
#   && make \
#   && make all \
#   && make install \
#   && make clean
#  && make distclean \
#RUN cd ${POSTGRESQL_HOME}
#RUN /sbin/ldconfig ${POSTGRESQL_HOME}/lib
#RUN rm -rf ${POSTGRESQL_INSTALL}

#RUN useradd postgres
#RUN chown -R postgres:postgres ${POSTGRESQL_HOME}

#COPY ./config/sonarqube/system/profile.d/shared-lib.sh /etc/profile.d/
#RUN chmod 0644 /etc/profile.d/shared-lib.sh
#COPY ./config/sonarqube/system/profile.d/postgres.sh /etc/profile.d/
#RUN chmod 0644 /etc/profile.d/postgres.sh
# pg_ctl -D /usr/share/postgresql/data -l logfile start
# COPY ./config/sonarqube/system/postgresql/pg_hba.conf /usr/share/postgresql/data/

#RUN tree -L 3 ${POSTGRESQL_HOME}
#RUN su -s /bin/bash -c "source /etc/profile.d/shared-lib.sh && source /etc/profile.d/postgres.sh && initdb -D ${POSTGRESQL_HOME}/data" \
# -g postgres postgres
# RUN find ${POSTGRESQL_HOME} -iname "pg_hba.conf"
# RUN cat /usr/share/postgresql/data/pg_hba.conf
#RUN systemctl start postgresql
# RUN systemctl enable postgresql

# /usr/share/postgresql/pgsql
#RUN tree -L 3 ${POSTGRESQL_HOME}
#RUN ls -la ${POSTGRESQL_HOME}/lib
# RUN /sbin/ldconfig ${POSTGRESQL_DIR}/pgsql/lib
#RUN dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
#RUN dnf install python2-libs -y
#RUN dnf repolist
#RUN dnf --repo pgdg12 install postgresql12.x86_64 -y
#RUN dnf --repo pgdg12 install postgresql12-server.x86_64 -y
#RUN /usr/pgsql-12/bin/postgresql-12-setup initdb
#RUN systemctl enable postgresql-12
#RUN systemctl start postgresql-12
#RUN service postgresql-12 start

# Postgres installation done

# SonarQube installation
ENV APP_USER sonarqube
ENV APP_GROUP gsonarqube
ENV APP_HOME /usr/share/sonarqube
ENV SONARQUBE_NAME sonarqube
ENV SONARQUBE_VERSION 8.0
ENV SONARQUBE_HOME ${APP_HOME}/${SONARQUBE_NAME}-${SONARQUBE_VERSION}
ENV SONARQUBE_FILE ${SONARQUBE_NAME}-${SONARQUBE_VERSION}.zip
ENV SONARQUBE_PROFILE_FILE /etc/profile.d/sonarqube.sh
ENV SONARQUBE_SERVICE ${SONARQUBE_HOME}/bin/linux-x86-64
ENV PATH ${PATH}:${SONARQUBE_HOME}/bin
ENV SONARQUBE_PORT 9000

RUN addgroup -S ${APP_GROUP} && adduser -S ${APP_USER} -G ${APP_GROUP}
RUN mkdir ${APP_HOME}
RUN wget https://binaries.sonarsource.com/Distribution/${SONARQUBE_NAME}/${SONARQUBE_FILE} \
    -P ${APP_HOME}
RUN unzip ${APP_HOME}/${SONARQUBE_FILE} -d ${APP_HOME}
RUN echo "export SONARQUBE_HOME=/usr/share/sonarqube/sonarqube-8.0" > ${SONARQUBE_PROFILE_FILE} && \
    echo "export PATH=\${PATH}:\${SONARQUBE_HOME}/bin" >> ${SONARQUBE_PROFILE_FILE} && \
    cat ${SONARQUBE_PROFILE_FILE} && source ${SONARQUBE_PROFILE_FILE}
RUN rm -rf ${APP_HOME}/${SONARQUBE_FILE}
COPY ./config/sonarqube/system/usr/share/sonarqube/.bash_profile ${APP_HOME}/
RUN chmod 0644 ${APP_HOME}/.bash_profile
COPY ./config/sonarqube/system/usr/share/sonarqube/.bashrc ${APP_HOME}/
RUN chmod 0644 ${APP_HOME}/.bashrc
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
RUN ls -la ${SONARQUBE_HOME}
RUN ls -la ${SONARQUBE_HOME}/conf
# SonarQube installation done

EXPOSE ${SONARQUBE_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER ${APP_USER}

# Node container has one and only one application running. It acts as SOLID principles.
# Dokcer can't use environment variable here.
ENTRYPOINT ["/usr/share/sonarqube/sonarqube-8.0/bin/linux-x86-64/sonar.sh", "start"]
