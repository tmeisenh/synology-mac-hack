#!/usr/bin/env bash

function is_mounted() {
	mount | grep $1 >/dev/null && echo "mounted" || echo "unmounted"
}

## example usage for ensuring a share 'stuff' is always mounted
if [[ $(is_mounted stuff) == "unmounted" ]]; then
	echo "stuff is not mounted $(date)"
	osascript -e "mount volume \"smb://${NASUSERID}:${NASPASSWORD}@nas/stuff\""
fi
