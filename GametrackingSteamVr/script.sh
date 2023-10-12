#!/bin/bash

set -eu
# if SSH_KEY is set to a non empty string save it in id_ed25519 if it doesn't exist
[ -n "$SSH_KEY" ] && [ ! -f ~/.ssh/id_ed25519 ] && echo "$SSH_KEY" > ~/.ssh/id_ed25519
[ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
[ -n "$GPG_KEY" ] && gpg --batch --import <( echo "$GPG_KEY")
[ -n "$GPG_KEY_ID" ] && git config --global user.signingkey "$GPG_KEY_ID"
[ -f ~/.ssh/id_ed25519 ] && chmod 600 ~/.ssh/id_ed25519

cd git_folder
# only clone if the directory doesn't exist
if [ ! -d "GameTracking" ]; then
    git clone --depth=1 https://github.com/SteamDatabase/GameTracking.git 
    cd GameTracking
else
    cd GameTracking
    git fetch
    git reset --hard origin/master
fi

# create .support if it doesn't exist
[ ! -d ".support" ] && mkdir .support
# link elfstrings if it doesn't exist
[ ! -L ".support/elfstrings" ] && ln -s ~/elfstrings .support/elfstrings
# link vpktool if it doesn't exist
[ ! -L ".support/vpktool" ] && ln -s ~/VPKTool/vpktool .support/vpktool

# only clone if the directory doesn't exist
if [ ! -d "steamvr" ]; then
    git clone $GAMETRACKING_STEAMVR_GIT_URL steamvr
    cd steamvr
else
    cd steamvr
    git fetch
    git reset --hard origin/master
fi

# dotnet ~/DepotDownloader/DepotDownloader.dll
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250821 -dir . -beta beta -filelist "/data/list/250821.txt"
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250823 -dir . -beta beta -filelist "/data/list/250823.txt"
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250824 -dir . -beta beta -filelist "/data/list/250824.txt"
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250827 -dir . -beta beta -filelist "/data/list/250827.txt"
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250830 -dir . -beta beta -filelist "/data/list/250830.txt"
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250833 -dir . -beta beta -filelist "/data/list/250833.txt"
~/DepotDownloader/DepotDownloader -username "$STEAM_USERNAME" -password "$STEAM_PASSWORD" -app 250820 -all-platforms -depot 250832 -dir . -beta beta -filelist "/data/list/250832.txt"
~/DepotDownloader/DepotDownloader -app 250820 -all-platforms -depot 250825 -dir . -beta beta
npm install

./update.sh