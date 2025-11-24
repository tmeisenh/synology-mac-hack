#!/bin/bash

# Fail fast: required env vars
required_env=(NASUSERID NASPASSWORD GMAIL_USER ALERT_EMAIL)
missing=()
for v in "${required_env[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    missing+=("$v")
  fi
done
if ((${#missing[@]})); then
  printf 'Error: missing required env var(s): %s\n' "${missing[*]}" >&2
  exit 1
fi

# Fail fast: required netrc file (NETRC_FILE or default)
netrc_path="${NETRC_FILE:-$HOME/.netrc-gmail}"
if [[ ! -f "$netrc_path" ]]; then
  printf 'Error: netrc file not found at %s (set NETRC_FILE or create ~/.netrc-gmail)\n' "$netrc_path" >&2
  exit 1
fi

is_mounted() {
  local share="$1"
  local mp="/Volumes/$share"
  # Lines look like: ... on /Volumes/<share> (smbfs, ...)
  if mount | grep -F " on ${mp} " >/dev/null; then
    echo "mounted"
  else
    echo "unmounted"
  fi
}

# expects: GMAIL_USER, ALERT_EMAIL exported
# expects: NETRC_FILE set (default: ~/.netrc-gmail)
notify_unmounted_batch() {
  local shares=("$@")
  local netrc="${NETRC_FILE:-$HOME/.netrc-gmail}"

  {
    echo "From: ${GMAIL_USER}"
    echo "To: ${ALERT_EMAIL}"
    echo "Subject: Mount alert: ${#shares[@]} share(s) not mounted"
    echo
    printf "Host: %s\nTime: %s\n" "$(hostname)" "$(date)"
    echo "Shares:"
    printf ' - %s\n' "${shares[@]}"
  } | curl --silent --show-error --ssl-reqd --url 'smtps://smtp.gmail.com:465' \
           --mail-from "${GMAIL_USER}" \
           --mail-rcpt "${ALERT_EMAIL}" \
           --netrc-file "${netrc}" \
           --upload-file -
}

shares=(directories go here)
unmounted_shares=()

# Assumes share name is same as mount point (very likely)
for share in "${shares[@]}"; do
    echo "Checking $share... $(date)"
  if [[ $(is_mounted "$share") == "unmounted" ]]; then
    echo "$share is not mounted $(date)"
    osascript -e "mount volume \"smb://${NASUSERID}:${NASPASSWORD}@nas/$share\"" || true
    # Recheck if mounting was successful and only email if it failed again
    [[ $(is_mounted "$share") == "unmounted" ]] && unmounted_shares+=("$share")
  fi
done

if ((${#unmounted_shares[@]})); then
  notify_unmounted_batch "${unmounted_shares[@]}"
fi