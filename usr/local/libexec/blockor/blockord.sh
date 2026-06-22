#!/bin/sh
#
# Copyright (c) 2022-2026, Muktadiur Rahman <muktadiur@gmail.com>
# All rights reserved.
#
# blockord - the blockor log watcher. Tails one or more auth logs, counts
# failures per source address inside a sliding window, and bans offenders via
# the PF <blockor> table. A background loop expires bans after bantime.

blockor_conf="/usr/local/etc/blockor.conf"
blockor_subr="/usr/local/libexec/blockor/blockor.subr"

# Refuse to source a config that any non-root user could have tampered with.
if [ -f "$blockor_conf" ] && [ -n "$(find "$blockor_conf" -perm +022 2>/dev/null)" ]; then
    echo "blockord(insecure permissions on $blockor_conf; must not be group/world writable)" >&2
    exit 1
fi

. "$blockor_conf"
. "${blockor_subr:-/usr/local/libexec/blockor/blockor.subr}"

bo_ensure_dirs
bo_load_whitelist
bo_restore_bans

# Files to watch: auth_files (space separated) overrides the single auth_file.
watch_files=${auth_files:-$auth_file}

rm -f "$fifo_file"
if ! mkfifo "$fifo_file" 2>/dev/null; then
    echo "blockord(could not create fifo $fifo_file)" >&2
    exit 1
fi

# One `tail -F` per file so log rotation is followed by name and no multi-file
# header lines leak into the stream. All writers feed the same fifo.
tail_pids=""
for f in $watch_files; do
    tail -n 0 -F "$f" >> "$fifo_file" 2>/dev/null &
    tail_pids="$tail_pids $!"
done

# Periodically prune the failure window and release expired bans.
( while sleep "$expire_interval"; do bo_prune_failures; bo_expire_bans; done ) &
expire_pid=$!

echo $$ > "$pid_file"

cleanup() {
    trap - INT TERM EXIT
    # shellcheck disable=SC2086
    kill $tail_pids "$expire_pid" 2>/dev/null
    rm -f "$fifo_file" "$pid_file"
    bo_log "blockord stopped (pid $$)"
    exit 0
}
trap cleanup INT TERM EXIT

bo_log "blockord started (pid $$): watching ${watch_files}"

while IFS= read -r line; do
    bo_process_line "$line"
done < "$fifo_file"
