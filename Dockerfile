FROM ubuntu:18.04
LABEL maintainer="Max Gonzih <gonzih at gmail dot com>"

ENV USER   csgo
ENV HOME   /home/${USER}
ENV SERVER ${HOME}/hlserver

ENV LOCALE en_US.UTF-8

ENV LC_ALL   ${LOCALE}
ENV LANG     ${LOCALE}
ENV LANGUAGE ${LOCALE}

RUN apt-get -qqy update \
    && apt-get -qqy install lib32gcc1 curl net-tools lib32stdc++6 locales \
    && locale-gen ${LOCALE} \
    && update-locale LANG=${LOCALE} LANGUAGE=${LOCALE} LC_ALL=${LOCALE} \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && rm -rf /tmp/* /var/tmp/* \
    && useradd ${USER} \
    && mkdir ${HOME} \
    && chown ${USER}:${USER} ${HOME} \
    && mkdir ${SERVER}

ADD ./docker/csgo_ds.txt  ${SERVER}/csgo_ds.txt
ADD ./docker/update.sh    ${SERVER}/update.sh
ADD ./docker/autoexec.cfg ${SERVER}/csgo/csgo/cfg/autoexec.cfg
ADD ./docker/server.cfg   ${SERVER}/csgo/csgo/cfg/server.cfg
ADD ./docker/csgo.sh      ${SERVER}/csgo.sh

RUN chown -R ${USER}:${USER} ${SERVER}

USER ${USER}

RUN curl -sSL http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C ${SERVER} -xvz \
    && ${SERVER}/update.sh

EXPOSE 27015/udp

WORKDIR ${SERVER}

ENTRYPOINT ["./csgo.sh"]

CMD ["-console" "-usercon" "+game_type" "0" "+game_mode" "1" "+mapgroup" "mg_active" "+map" "de_cache"]
