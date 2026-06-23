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
# (portable check: ls perm string, group-write at col 6 or other-write at col 9.
# ls is fine here - the path is fixed; find -perm +mode is not portable to OpenBSD.)
if [ -f "$blockor_conf" ]; then
    # shellcheck disable=SC2012
    _perm=$(ls -ld "$blockor_conf" 2>/dev/null | cut -c1-10)
    case "$_perm" in
    ?????w????|????????w?)
        printf 'blockord: error: %s is group/world writable; refusing to run\n' "$blockor_conf" >&2
        exit 1
        ;;
    esac
fi

# shellcheck source=/dev/null
. "$blockor_conf"
# shellcheck source=blockor.subr
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

# Follow flag: FreeBSD's tail has -F (follow by name across log rotation);
# OpenBSD's tail only has -f, so fall back to it there.
case "$(uname -s)" in
OpenBSD) tail_follow='-f' ;;
*)       tail_follow='-F' ;;
esac

# One tail per file (so no multi-file header lines leak into the stream); all
# writers feed the same fifo.
tail_pids=""
for f in $watch_files; do
    # shellcheck disable=SC2086
    tail -n 0 $tail_follow "$f" >> "$fifo_file" 2>/dev/null &
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
