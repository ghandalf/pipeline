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

# Nexus installation
ENV APP_USER nexus
ENV APP_GROUP ngroup
ENV APP_HOME /usr/share/nexus
ENV NEXUS_VERSION latest
ENV NEXUS_FINAL_NAME nexus-${NEXUS_VERSION}
ENV NEXUS_FILE ${NEXUS_VERSION}-unix.tar.gz
ENV NEXUS_HOME ${APP_HOME}/${NEXUS_FINAL_NAME}
ENV NEXUS_DATA ${APP_HOME}/data
ENV NEXUS_PORT 32280

RUN addgroup -S ${APP_GROUP} && adduser -S ${APP_USER} -G ${APP_GROUP}
RUN mkdir -p ${APP_HOME} ${NEXUS_DATA}/etc ${NEXUS_DATA}/logs ${NEXUS_DATA}/tmp
RUN wget https://download.sonatype.com/nexus/3/${NEXUS_FILE} -P ${APP_HOME}
RUN tar xvf ${APP_HOME}/${NEXUS_FILE} -C ${APP_HOME}/ && \
    mv ${APP_HOME}/nexus-* ${APP_HOME}/${NEXUS_FINAL_NAME} && \
    rm -rf ${APP_HOME}/${NEXUS_FILE}
COPY ./config/nexus/system/service.sh ${APP_HOME}/
COPY ./config/nexus/system/conf/bin/nexus.vmoptions ${NEXUS_HOME}/bin/
COPY ./config/nexus/system/conf/etc/nexus.properties ${NEXUS_DATA}/etc/
RUN chmod 0755 ${APP_HOME}/service.sh
RUN ls -la ${APP_HOME}/
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
# Nexus installation done

EXPOSE ${NEXUS_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER ${APP_USER}

ENTRYPOINT ["/usr/share/nexus/service.sh", "start"]