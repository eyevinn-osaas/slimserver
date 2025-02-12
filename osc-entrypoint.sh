#!/bin/bash

if [ ! -d /data/config ]; then
    mkdir -p /data/config
fi

if [ ! -d /data/playlist ]; then
    mkdir -p /data/playlist
fi

if [ ! -d /data/music ]; then
    mkdir -p /data/music
fi

# Copy music files from S3 bucket
if [ -z "$MUSIC_BUCKET_URL" ]; then
    echo "MUSIC_BUCKET_URL is not set. Skipping copying music files."
else
    echo "Copying music files from S3 bucket $MUSIC_BUCKET"
    if [ ! -z "$S3_ENDPOINT_URL" ]; then
      aws s3 --endpoint "$S3_ENDPOINT_URL" sync $MUSIC_BUCKET_URL /data/music
    else
      aws s3 sync $MUSIC_BUCKET_URL /data/music
    fi
fi

#Set user and group
umask 0002
PUID=${PUID:-`id -u squeezeboxserver`}
PGID=${PGID:-`id -g squeezeboxserver`}

usermod -o -u "$PUID" squeezeboxserver
groupmod -o -g "$PGID" squeezeboxserver

chown -R squeezeboxserver:squeezeboxserver /data/config /data/playlist

su squeezeboxserver -c '/usr/bin/perl /lms/slimserver.pl --prefsdir /data/config/prefs --logdir /data/config/logs --cachedir /data/config/cache --httpport $PORT $@'
