FROM alpine:3.15

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

# Maven installation
ENV MAVEN_NAME apache-maven
ENV MAVEN_VERSION 3.6.2
ENV MAVEN_DIR /usr/share/maven
ENV MAVEN_HOME ${MAVEN_DIR}/${MAVEN_NAME}-${MAVEN_VERSION}
ENV MAVEN_PROFILE_FILE /etc/profile.d/maven.sh
ENV MAVEN_FILE ${MAVEN_NAME}-${MAVEN_VERSION}-bin.tar.gz
ENV PATH ${PATH}:${MAVEN_HOME}/bin

RUN apk add wget
RUN mkdir -p ${MAVEN_DIR}
RUN wget http://apache.mirror.iweb.ca/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_FILE} -P ${MAVEN_DIR}
RUN tar xvf ${MAVEN_DIR}/${MAVEN_NAME}*.tar.gz -C ${MAVEN_DIR}/
RUN echo "export MAVEN_HOME=/usr/share/maven/apache-maven-3.6.2" > ${MAVEN_PROFILE_FILE} && \
    echo "export PATH=\${PATH}:\${MAVEN_HOME}/bin" >> ${MAVEN_PROFILE_FILE} && \
    cat ${MAVEN_PROFILE_FILE} && source ${MAVEN_PROFILE_FILE}
RUN chmod 0644 /${MAVEN_PROFILE_FILE}
RUN rm -rf ${MAVEN_DIR}/${MAVEN_FILE}
RUN ${MAVEN_HOME}/bin/mvn -version
# Maven installation done

# Ant installation
ENV ANT_NAME apache-ant
ENV ANT_VERSION 1.10.7
ENV ANT_DIR /usr/share/ant
ENV ANT_HOME ${ANT_DIR}/${ANT_NAME}-${ANT_VERSION}
ENV ANT_PROFILE_FILE /etc/profile.d/ant.sh
ENV ANT_FILE ${ANT_NAME}-${ANT_VERSION}-bin.tar.gz
ENV PATH ${PATH}:${ANT_HOME}/bin

RUN mkdir -p ${ANT_DIR}
RUN wget http://apache.mirror.colo-serv.net//ant/binaries/${ANT_FILE} -P ${ANT_DIR}
RUN tar xvf ${ANT_DIR}/${ANT_FILE} -C ${ANT_DIR}/
RUN echo "export ANT_HOME=/usr/share/ant/apache-ant-1.10.7" > ${ANT_PROFILE_FILE} && \
    echo "export PATH=\${PATH}:\${ANT_HOME}/bin" >> ${ANT_PROFILE_FILE} && \
    cat ${ANT_PROFILE_FILE} && source ${ANT_PROFILE_FILE}
RUN chmod 0644 ${ANT_PROFILE_FILE}
RUN rm -rf ${ANT_DIR}/${ANT_FILE}
RUN ${ANT_HOME}/bin/ant -version
# Ant installation done

# Jenkins installation
ENV APP_USER jenkins
ENV APP_GROUP jgroup
ENV APP_HOME /usr/share/jenkins
ENV JENKINS_HOME ${APP_HOME}
ENV JENKINS_PORT 32380

RUN addgroup -S ${APP_GROUP} && adduser -S ${APP_USER} -G ${APP_GROUP}
RUN mkdir -p ${APP_HOME} ${APP_HOME}/bin ${APP_HOME}/.m2
RUN wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war -P ${APP_HOME}/bin
COPY ./config/jenkins/system/service.sh /usr/share/jenkins/
COPY ./config/jenkins/system/.m2/settings.xml /usr/share/jenkins/.m2/
COPY ./config/jenkins/system/.m2/settings-security.xml /usr/share/jenkins/.m2/
COPY ./config/jenkins/system/usr/share/jenkins/.bash_profile /usr/share/jenkins/
COPY ./config/jenkins/system/usr/share/jenkins/.bashrc /usr/share/jenkins/
RUN chmod 0644 ${APP_HOME}/.bash_profile && \
    chmod 0644 ${APP_HOME}/.bashrc && \
    chmod 0755 ${APP_HOME}/service.sh
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
RUN ls -la ${JENKINS_HOME} && ls -la ${JENKINS_HOME}/bin
# Jenkins installation done

EXPOSE ${JENKINS_PORT}

# Tell docker that all future commands should run as the appuser user
USER ${APP_USER}

# Dokcer can't use environment variable here.
ENTRYPOINT ["/usr/share/jenkins/service.sh", "start"]
#ENTRYPOINT ["sh", "/usr/share/jenkins/service.sh", "start"]
