FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV PUID=99 PGID=100
ENV PORT=8080

RUN apt-get update -qq  && \
	apt-get install --no-install-recommends -qy wget curl perl tzdata libcrypt-blowfish-perl libwww-perl libfont-freetype-perl liblinux-inotify2-perl \
	libdata-dump-perl libio-socket-ssl-perl libnet-ssleay-perl libcrypt-ssleay-perl libcrypt-openssl-rsa-perl libssl-dev libgomp1 libasound2 lame awscli && \
	apt-get clean -qy && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN useradd squeezeboxserver && \
	usermod -u $PUID squeezeboxserver && \
	groupmod -o -g "$PGID" squeezeboxserver && \
	usermod -d /home squeezeboxserver && \
	usermod -a -G audio squeezeboxserver

COPY osc-entrypoint.sh /usr/local/bin/osc-entrypoint.sh
RUN chmod +x /usr/local/bin/osc-entrypoint.sh

WORKDIR /lms
COPY . .
COPY ./Slim-Utils-OSC.pm /lms/Slim/Utils/OS/Custom.pm

VOLUME /data

EXPOSE 3483 3483/udp ${PORT} 9090

ENTRYPOINT ["/usr/local/bin/osc-entrypoint.sh"]
