#!/bin/bash

set -eu

[ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
[ -n "$GPG_KEY" ] && gpg --batch --import <( echo "$GPG_KEY")
[ -n "$GPG_KEY_ID" ] && git config --global user.signingkey "$GPG_KEY_ID"

echo ".DepotDownloader" >> ~/.gitignore && \
git config --global core.excludesfile ~/.gitignore && \

[ ! -d ~/ValveProtobufs ] && ln -s /data/ValveProtobufs ~/ValveProtobufs

mv /data/GameTracking /github/workspace/GameTracking

cd /github/workspace/GameTracking

#mkdir -p /github/workspace/csgo
#ln -s /github/workspace/csgo csgo 

git clone --branch $GITHUB_REF_NAME --single-branch https://$GITHUB_APP_ID:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git csgo

cd csgo

if [ ! -f DumpSource2/.stringsignore ]; then
    touch DumpSource2/.stringsignore
fi

mkdir -p ./manifests

[ -z "$STEAM_BRANCH" ] && STEAM_BRANCH="public"

# 817940
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 730 -depot 2347770 2347771 2347773 2347779 -all-platforms -dir ./manifests -beta $STEAM_BRANCH -manifest-only
shopt -s extglob
for file in ./manifests/*_*_*.txt; do
    mv $file ${file%_+([0-9]).txt}.txt
done
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 730 -all-platforms -depot 2347770 -validate -dir . -beta $STEAM_BRANCH -filelist "/data/list/2347770.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 730 -all-platforms -depot 2347771 -validate -dir . -beta $STEAM_BRANCH -filelist "/data/list/2347771.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 730 -all-platforms -depot 2347773 -validate -dir . -beta $STEAM_BRANCH -filelist "/data/list/2347773.txt"
/data/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 730 -all-platforms -depot 2347779 -validate -dir . -beta $STEAM_BRANCH -filelist "/data/list/2347779.txt"

./update.sh $STEAM_BRANCH