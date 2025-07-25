# this is for local testing only

FROM ubuntu:24.04 AS install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17.0.13_11-jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ADD PROGRESS_OE.tar.gz /install/openedge/
ADD PROGRESS_PATCH_OE.tar.gz /install/patch/
ADD scripts/install-openedge.sh /install/

COPY oe128-db-dev-response.ini /install/openedge/response.ini
ENV TERM=xterm

RUN /install/install-openedge.sh
RUN cat /install/install_oe.log

RUN rm -f /usr/dlc/progress.cfg 

# multi stage build, this give the possibilty to remove all the slack from stage 0
FROM ubuntu:24.04 AS instance

LABEL maintainer="Bronco Oostermeyer <dev@bfv.io>"

ENV JAVA_HOME=/opt/java/openjdk
ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk
ENV TERM=linux

COPY --from=install $JAVA_HOME $JAVA_HOME
COPY --from=install $DLC $DLC
COPY --from=install $WRKDIR $WRKDIR

COPY protocols /etc/
COPY services /etc/
RUN chmod 644 /etc/protocols && \
    chmod 644 /etc/services

WORKDIR /usr/dlc/bin

RUN chown root _* && \
    chmod 4755 _* && \
    chmod 755 _sql* && \
    chmod -f 755 _waitfor || true

ENV PATH=$DLC:$DLC/bin:$PATH:${JAVA_HOME}/bin:${PATH}

# ubuntu 24.04 has the user ubuntu as user 1000, which is not compatible with the openedge installation
# this user is removed and replaced with a new user openedge with uid 1000
RUN userdel -r ubuntu && \
    groupadd -g 1000 openedge && \
    useradd -r -u 1000 -g openedge openedge

# allow for progress.cfg to be copied into $DLC
# kubernetes does not support volume mount of single files
RUN chown root:openedge $DLC
RUN chmod 775 $DLC

RUN touch /usr/dlc/progress.cfg  && \
    chown openedge:openedge /usr/dlc/progress.cfg

# create directories and files as root
RUN \
  mkdir /app/ && \
  mkdir /app/backup/ && \
  mkdir /app/config/ && \
  mkdir /app/db/ && \
  mkdir /app/schema/ && \
  mkdir /app/scripts/ && \
  mkdir /app/tmp

COPY scripts/* /app/scripts/
RUN chmod +x /app/scripts/*.sh

# turn them over to user 'openedge'
RUN chown -R openedge:openedge /app/ 

USER openedge

VOLUME /app/db
VOLUME /app/schema

WORKDIR /app/db

CMD [ "bash", "-c", "/app/scripts/startdb.sh" ]
