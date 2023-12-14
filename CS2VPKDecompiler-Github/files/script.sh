#!/bin/bash
export LC_ALL=C

set -e

cd "${0%/*}"

[ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"

DEPOT_LIST="2347770"

ProcessVPK ()
{
	echo "> Processing VPKs"
	set +e
	while IFS= read -r -d '' file
	do
		echo " > $file"

		for ext in "vsvg_c,vpost_c,vpdi_c,csgoitem_c,econitem_c,vdata_c,res,vrman_c,vsc,ini,nav,csv,css,cfg,vanmgrph_c,vpcf_c,vmap_c,vwrld_c"
		do
			/data/Decompiler/Decompiler \
				--input "$file" \
				--output "$(echo "$file" | sed -e 's/\.vpk$/\//g')" \
				--vpk_decompile \
				--vpk_extensions "$ext" \
				&
		done
	done <   <(find . -type f -name "*_dir.vpk" -print0)
	wait
	set -e
}

FixUCS2 ()
{
	echo "> Fixing UCS-2"
	echo "$(dirname "${BASH_SOURCE[0]}")"
	find . -type f -name "*.txt" -print0 | xargs --null --max-lines=1 --max-procs=3 "/data/fix_encoding"
}

CreateCommit ()
{
	message="$1 | $(git status --porcelain | wc -l) files | $(git status --porcelain | sed '{:q;N;s/\n/, /g;t q}' | sed 's/^ *//g' | cut -c 1-1024)"
	git add -A
	
	if ! git diff-index --quiet HEAD; then
		git commit -a -m "$message"
		git push
	fi
	
	#~/ValveProtobufs/update.sh
}

cd $GITHUB_WORKSPACE

echo "Cleaning CS2"

find . -type f -not \( -path './README.md' -o -path './.git*' -o -path '*.vpk' -o -path "steam.inf" -o -path "./.DepotDownloader" \) -delete 
find . -type d -empty -a -not \( -path './.git*' -o -path "./.DepotDownloader" \) -delete

echo "Downloading CS2"

#if we don't have manifests, we use the latest manifest that steam provides us with
#otherwise we use the manifests that we have

if [ -z "$MANIFESTS" ]; then
	/data/DepotDownloader/DepotDownloader -app 730 -depot $DEPOT_LIST -dir . -filelist "/data/vpk.txt" -validate
else
	#idk why i have to do this in such a weird way but it works
	depots=""
	manifests=""
	while IFS=' ' read -ra depot_manifest; do
		for dm in "${depot_manifest[@]}"; do
			IFS='_' read -ra dm_split <<< "$dm"
			depots+="${dm_split[0]} "
			manifests+="${dm_split[1]} "
		done
	done <<< "$MANIFESTS"
	
	/data/DepotDownloader/DepotDownloader -app 730 -depot $depots -manifest $manifests -dir . -filelist "/data/vpk.txt" -validate
fi

echo "Processing CS2"

ProcessVPK

FixUCS2

CreateCommit "$(grep "ClientVersion=" game/csgo/steam.inf | grep -o '[0-9\.]*')"