# Contributing to blockor

Thanks for helping improve blockor!

## Ground rules

- **POSIX `/bin/sh` only** for `blockor`, `blockord.sh`, and `blockor.subr`
  (the OpenBSD rc.d script is `ksh`). Avoid bashisms so it runs on FreeBSD and
  OpenBSD out of the box.
- Keep blockor **dependency-free**. The only tools used are the base system:
  `pfctl`, `tail`, `grep`, `sed`, `awk`, `logger`, `mail`.
- Quote your variables and prefer `awk`/`grep -F` over fragile regex when
  matching addresses.

## Before opening a PR

1. Run the test harness:

   ```sh
   make test        # or: sh tests/run_tests.sh
   ```

2. Lint (if you have it installed):

   ```sh
   shellcheck -s sh usr/local/bin/blockor \
       usr/local/libexec/blockor/blockord.sh \
       usr/local/libexec/blockor/blockor.subr
   ```

3. Add a test in `tests/run_tests.sh` for any behaviour change. The harness
   stubs `pfctl`, so most logic can be tested without a real PF setup.

4. Update `CHANGELOG.md`, and the man page / `README.md` if behaviour or
   options changed.

## Project layout

```
usr/local/bin/blockor                 CLI
usr/local/libexec/blockor/blockord.sh log watcher daemon
usr/local/libexec/blockor/blockor.subr shared functions (sourced by both)
freebsd/ , openbsd/                    per-OS conf, rc.d, man, examples
tests/run_tests.sh                     test harness
```

## Reporting security issues

Please report suspected security problems privately to
<muktadiur@gmail.com> rather than opening a public issue.
