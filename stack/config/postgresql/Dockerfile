FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 8"

ENV CONTAINER_NAME postgresql
ENV CONTAINER_IMAGE ghandalf/${CONTAINER_NAME}:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV ROOT_DIR /usr/share

# PostgreSQL
ENV POSTGRESQL_NAME postgresql
ENV POSTGRESQL_HOME ${ROOT_DIR}/${POSTGRESQL_NAME}
ENV POSTGRESQL_VERSION 12
ENV POSTGRESQL_PORT 5432
ENV APP_USER postgres
ENV APP_GROUP postgres

RUN dnf update -y
RUN dnf install tree net-tools bind-utils wget -y
RUN dnf groupinstall 'Development Tools' -y
RUN dnf install readline-devel zlib-devel -y

# Postgres installation
RUN mkdir -p ${POSTGRESQL_HOME}
RUN wget https://ftp.postgresql.org/pub/source/v12.0/postgresql-12.0.tar.gz -P ${POSTGRESQL_HOME}
RUN tar -xz -f ${POSTGRESQL_HOME}/postgresql-12.0.tar.gz -C ${POSTGRESQL_HOME}
ENV POSTGRESQL_INSTALL ${POSTGRESQL_HOME}/postgresql-12.0

RUN cd ${POSTGRESQL_INSTALL} \
   && ./configure --prefix=${POSTGRESQL_HOME} \
   && make \
   && make all \
   && make install \
   && make clean
#   && make distclean \
RUN cd ${POSTGRESQL_HOME}
RUN /sbin/ldconfig ${POSTGRESQL_HOME}/lib
RUN rm -rf ${POSTGRESQL_INSTALL}

RUN useradd ${APP_USER}
RUN chown -R ${APP_USER}:${APP_GROUP} ${POSTGRESQL_HOME}

COPY ./config/postgresql/system/profile.d/postgres.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/postgres.sh
# pg_ctl -D /usr/share/postgresql/data -l logfile start
# COPY ./config/postgresql/system/postgresql/pg_hba.conf /usr/share/postgresql/data/

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

EXPOSE ${POSTGRESQL_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER postgres
RUN id postgres
# Node container has one and only one application running. It acts as SOLID principles.
# Dokcer can't use environment variable here.
# ENTRYPOINT ["/usr/share/postgresql/service.sh", "start"]
# ENTRYPOINT ["service", "postgresql",  "start"]

# https://www.postgresql.org/docs/current/server-start.html
#ENTRYPOINT ["/usr/share/postgresql//bin/postgres", "-D",  "/usr/share/postgresql/data"]
ENTRYPOINT ["su postgres /bin/bash"]