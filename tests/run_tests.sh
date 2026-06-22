#!/bin/sh
#
# blockor test harness. Stubs pfctl/logger/mail, sources blockor.subr against a
# temp state directory, and asserts the pure logic (no real PF needed).
# Run: sh tests/run_tests.sh

set -u

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
subr="$repo/usr/local/libexec/blockor/blockor.subr"

work=$(mktemp -d "${TMPDIR:-/tmp}/blockor.test.XXXXXX")
trap 'rm -rf "$work"' EXIT

bindir="$work/bin"
mkdir -p "$bindir"

# --- stub pfctl: maintains one file per table under $PFSTUB_DIR ---
PFSTUB_DIR="$work/pf"
mkdir -p "$PFSTUB_DIR"
cat > "$bindir/pfctl" <<'STUB'
#!/bin/sh
dir=${PFSTUB_DIR}
table=""; sub=""; ips=""
while [ $# -gt 0 ]; do
    case $1 in
        -t) table=$2; shift 2 ;;
        -T) sub=$2; shift 2 ;;
        -q) shift ;;
        -s*) shift ;;
        *) ips="$ips $1"; shift ;;
    esac
done
f="$dir/table_${table}"
touch "$f"
case "$sub" in
    add) for ip in $ips; do grep -qxF "$ip" "$f" || echo "$ip" >> "$f"; done ;;
    delete) for ip in $ips; do grep -vxF "$ip" "$f" > "$f.t" 2>/dev/null; mv "$f.t" "$f"; done ;;
    test) ok=1; for ip in $ips; do grep -qxF "$ip" "$f" && ok=0; done; exit $ok ;;
    show) cat "$f" ;;
    flush) : > "$f" ;;
esac
exit 0
STUB
chmod +x "$bindir/pfctl"

# logger/mail no-ops so notifications don't error in tests
printf '#!/bin/sh\nexit 0\n' > "$bindir/logger"; chmod +x "$bindir/logger"
printf '#!/bin/sh\nexit 0\n' > "$bindir/mail"; chmod +x "$bindir/mail"

export PFSTUB_DIR
PATH="$bindir:$PATH"
export PATH

# --- config the subr will pick up ---
db_dir="$work/db"
run_dir="$work/run"
blockor_log_file="$work/blockord.log"
max_tolerance=3
findtime=600
bantime=3600
expire_interval=60
blockor_whitelist="9.9.9.9 10.0.0.0/8"
notify_syslog="NO"
search_pattern="PAM: Authentication error|Failed password|Invalid user|Unable to negotiate with|Bad protocol version identification|Disconnected from authenticating user root"

# shellcheck source=../usr/local/libexec/blockor/blockor.subr
. "$subr"
bo_ensure_dirs

pass=0; fail=0
ok()   { pass=$((pass+1)); printf '  ok   - %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf '  FAIL - %s\n' "$1"; }
eq()   { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (want [$3] got [$2])"; fi; }
yes()  { if "$2" "$3" >/dev/null 2>&1; then ok "$1"; else bad "$1 (expected match)"; fi; }
no()   { if "$2" "$3" >/dev/null 2>&1; then bad "$1 (expected no match)"; else ok "$1"; fi; }

echo "== portable output glyphs (octal, not \\x) =="
glyph_hex=$(bo_ok "x" | od -An -tx1 | tr -d ' \n')
case "$glyph_hex" in
    *e29c93*) ok "bo_ok emits UTF-8 check mark (U+2713)" ;;
    *) bad "bo_ok glyph wrong/garbled: $glyph_hex" ;;
esac

echo "== human-readable durations =="
eq "seconds" "$(bo_human_time 45)"   "45s"
eq "minutes" "$(bo_human_time 600)"  "10m"
eq "hours"   "$(bo_human_time 3600)" "1h"
eq "hours+min" "$(bo_human_time 3720)" "1h2m"
eq "days"    "$(bo_human_time 259200)" "3d"
eq "negative clamps to 0s" "$(bo_human_time -5)" "0s"

echo "== IP extraction =="
eq "ipv4 from sshd line" \
   "$(bo_extract_ip 'Jun 23 01:44:30 host sshd[123]: Failed password for root from 203.0.113.7 port 22 ssh2')" \
   "203.0.113.7"
eq "ipv6 from sshd line" \
   "$(bo_extract_ip 'Jun 23 01:44:30 host sshd[123]: Failed password for root from 2001:db8::1 port 22 ssh2')" \
   "2001:db8::1"
eq "ipv4 with 'with' keyword" \
   "$(bo_extract_ip 'Jun 23 01:44:30 host sshd[7]: Unable to negotiate with 198.51.100.4 port 5: no matching')" \
   "198.51.100.4"
eq "timestamp not mistaken for ipv6" \
   "$(bo_extract_ip 'Jun 23 01:44:30 host sshd[7]: Failed password for root from 198.51.100.9 port 5')" \
   "198.51.100.9"

echo "== IP validation =="
yes "valid ipv4"            bo_valid_ip "192.168.1.1"
yes "valid ipv6"           bo_valid_ip "2001:db8::1"
yes "valid ipv6 loopback"  bo_valid_ip "::1"
no  "reject 999 octet"     bo_valid_ip "999.1.1.1"
no  "reject trailing junk" bo_valid_ip "1.2.3.4.5"
no  "reject garbage"       bo_valid_ip "not-an-ip"

echo "== whitelist (fixes the add bug) =="
yes "exact ip whitelisted"  bo_is_whitelisted "9.9.9.9"
no  "other ip not listed"   bo_is_whitelisted "203.0.113.7"

echo "== ban dedup =="
bo_ban "203.0.113.50" 5 0
bo_ban "203.0.113.50" 5 0
eq "banned once in table" "$(grep -c . "$PFSTUB_DIR/table_blockor")" "1"
eq "one line in bans file" "$(grep -c '203.0.113.50' "$bans_file")" "1"

echo "== windowed threshold + auto-ban =="
LINE='Jun 23 01:44:30 host sshd[1]: Failed password for root from 203.0.113.99 port 22'
bo_process_line "$LINE"
no  "not banned after 1 fail" bo_is_banned "203.0.113.99"
bo_process_line "$LINE"
no  "not banned after 2 fails" bo_is_banned "203.0.113.99"
bo_process_line "$LINE"
yes "banned after 3 fails (max_tolerance)" bo_is_banned "203.0.113.99"

echo "== whitelisted IP never banned =="
WL='Jun 23 01:44:30 host sshd[1]: Failed password for root from 9.9.9.9 port 22'
i=0; while [ $i -lt 6 ]; do bo_process_line "$WL"; i=$((i+1)); done
no "whitelisted ip stays unbanned" bo_is_banned "9.9.9.9"

echo "== ipv6 auto-ban =="
V6='Jun 23 01:44:30 host sshd[1]: Failed password for root from 2001:db8::dead port 22'
i=0; while [ $i -lt 3 ]; do bo_process_line "$V6"; i=$((i+1)); done
yes "ipv6 offender banned" bo_is_banned "2001:db8::dead"

echo "== bantime expiry =="
# old, expirable ban
printf '%s %s %s %s\n' "$(( $(bo_now) - 10000 ))" "203.0.113.200" "9" "3600" >> "$bans_file"
pfctl -t blockor -q -T add "203.0.113.200"
# permanent ban (bantime 0) must survive
printf '%s %s %s %s\n' "$(( $(bo_now) - 10000 ))" "203.0.113.201" "9" "0" >> "$bans_file"
pfctl -t blockor -q -T add "203.0.113.201"
bo_expire_bans
no  "expired ban released"     bo_is_banned "203.0.113.200"
yes "permanent ban survives"   bo_is_banned "203.0.113.201"

echo "== prune failures window =="
printf '%s %s\n' "$(( $(bo_now) - 10000 ))" "203.0.113.210" >> "$failures_file"
printf '%s %s\n' "$(bo_now)" "203.0.113.210" >> "$failures_file"
bo_prune_failures
eq "stale failure pruned, recent kept" \
   "$(grep -c '203.0.113.210' "$failures_file")" "1"

echo
echo "Passed: $pass  Failed: $fail"
[ "$fail" -eq 0 ]
