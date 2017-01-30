# AUTOGENERATED BY MAKE - DO NOT MODIFY MANUALLY
FROM resin/amd64-alpine

# Install ZIM (wikipedia etc) packages
ENV ZIM_URL http://download.kiwix.org/zim

RUN apk add --update openssl \
 && wget -O - https://download.kiwix.org/bin/kiwix-linux-x86_64.tar.bz2 \
      | tar -C / -xjf - \
 && mkdir -p /content/zim /content/kiwix/{library,index} \
 && for zim in wiktionary_en_simple_all.zim; do \
      wget -O /content/zim/$zim $ZIM_URL/$zim \
      && ls /content/zim \
      && /kiwix/bin/kiwix-index  /content/zim/$zim /content/kiwix/index \
      && /kiwix/bin/kiwix-manage /content/kiwix/library add /content/zim/$zim \
      ; \
    done


# Install httrack
RUN apk add --update -t build-deps build-base git zlib-dev openssl-dev \
 && git clone https://github.com/xroche/httrack.git --recurse \
      /usr/src/httrack \
 && cd /usr/src/httrack \
 && ./configure \
 && make -j8 \
 && make install \
 && apk del build-deps \
 && rm -rf /usr/src/*

# Mirror Websites
ENV SITES https://5pi.de
RUN mkdir -p /content/www \
 && cd /content/www \
 && httrack $SITES \
 && find . -type f -maxdepth 1 -delete \
 && rm -rf hts-cache

### CAUTION: CHANGES ABOVE THIS LINE WILL BUST THE CACHE ###

RUN apk add --update hostapd dnsmasq s6 nginx openssh \
 && sed -i 's/#PermitRootLogin.*/PermitRootLogin\ yes/' \
      /etc/ssh/sshd_config

COPY files /

VOLUME [ "/data" ]
EXPOSE 80


ENTRYPOINT [ "/run.sh" ]
