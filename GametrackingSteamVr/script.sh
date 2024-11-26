#!/bin/bash

set -eu

[ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
[ -n "$GPG_KEY" ] && gpg --batch --import <( echo "$GPG_KEY")
[ -n "$GPG_KEY_ID" ] && git config --global user.signingkey "$GPG_KEY_ID"

echo ".DepotDownloader" >> ~/.gitignore && \
git config --global core.excludesfile ~/.gitignore && \

[ ! -d ~/ValveProtobufs ] && ln -s /data/ValveProtobufs ~/ValveProtobufs

cd /data/GameTracking

git clone --branch $GITHUB_REF_NAME --single-branch https://$GITHUB_APP_ID:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git steamvr

cd steamvr

mkdir -p ./manifests

# 817940
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -depot 228985 228988 228989 228990 250821 250822 250823 250824 250825 250827 250828 250829 250830 250831 250832 250833 250834 -all-platforms -dir ./manifests -beta beta -manifest-only
shopt -s extglob
for file in ./manifests/*_*_*.txt; do
    mv $file ${file%_+([0-9]).txt}.txt
done
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250821 -validate -dir . -beta beta -filelist "/data/list/dll.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250823 250832 -validate -dir . -beta beta -filelist "/data/list/lib.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250824 -validate -dir . -beta beta -filelist "/data/list/big_content.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250827 250830 250833 -validate -dir . -beta beta -filelist "/data/list/content.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250834 -validate -dir . -beta beta 
/data/DepotDownloader/DepotDownloader -app 250820 -all-platforms -depot 250825 -dir . -beta beta
npm install

./update.sh