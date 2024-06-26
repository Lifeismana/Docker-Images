#!/bin/bash

set -eu

[ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
[ -n "$GPG_KEY" ] && gpg --batch --import <( echo "$GPG_KEY")
[ -n "$GPG_KEY_ID" ] && git config --global user.signingkey "$GPG_KEY_ID"

echo ".DepotDownloader" >> ~/.gitignore && \
git config --global core.excludesfile ~/.gitignore && \

cd $GITHUB_WORKSPACE

# create .support if it doesn't exist
[ ! -d ".support" ] && mkdir .support
# link elfstrings if it doesn't exist
[ ! -L ".support/elfstrings" ] && ln -s /data/elfstrings .support/elfstrings
# link vpktool if it doesn't exist
[ ! -L ".support/vpktool" ] && ln -s /data/VPKTool/vpktool .support/vpktool

# link ProtobufDumper if it doesn't exist
[ ! -L "~/ProtobufDumper" ] && ln -s /data/ProtobufDumper ~/ProtobufDumper
# link ValveResourceFormat if it doesn't exist
[ ! -L "~/ValveResourceFormat" ] && ln -s /data/ValveResourceFormat ~/ValveResourceFormat
# link ValveProtobufs if it doesn't exist
[ ! -L "~/ValveProtobufs" ] && ln -s /data/ValveProtobufs ~/ValveProtobufs

cd steamvr

mkdir -p ./driver

# dotnet /data/DepotDownloader/DepotDownloader.dll
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -dir ./driver -beta beta -manifest-only
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250821 -validate -dir . -beta beta -filelist "/data/list/dll.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250823 250832 -validate -dir . -beta beta -filelist "/data/list/lib.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250824 -validate -dir . -beta beta -filelist "/data/list/big_content.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250827 250830 250833 -validate -dir . -beta beta -filelist "/data/list/content.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250834 -validate -dir . -beta beta 
/data/DepotDownloader/DepotDownloader -app 250820 -all-platforms -depot 250825 -dir . -beta beta
npm install

./update.sh