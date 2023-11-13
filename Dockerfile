FROM ubuntu:20.04 as install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17.0.9_9-jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ADD PROGRESS_OE_12.7.0_LNX_64.tar.gz /install/openedge

COPY oe127-db-dev-response.ini /install/openedge/response.ini
ENV TERM xterm

RUN /install/openedge/proinst -b /install/openedge/response.ini -l /install/install_oe.log -n && \
    rm /usr/dlc/progress.cfg

# multi stage build, this give the possibilty to remove all the slack from stage 0
FROM ubuntu:20.04 as instance

LABEL maintainer="Bronco Oostermeyer <dev@bfv.io>"

ENV JAVA_HOME=/opt/java/openjdk
ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk

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

ENV TERM xterm
ENV PATH=$DLC:$DLC/bin:$PATH

RUN groupadd -g 1000 openedge && \
    useradd -r -u 1000 -g openedge openedge

# create directories and files as root
RUN \
  mkdir /app/ && \
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
