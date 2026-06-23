# Port skeletons

Starting points for packaging blockor as a FreeBSD port and an OpenBSD port.
They install the same files as `make install`, but the ports framework handles
config samples (`@sample`), the rc.d script, man pages, and clean
upgrade/deinstall.

> These are skeletons. The checksums (`distinfo`) are **not** included because
> they hash the released `v0.2.0` tarball — generate them on a BSD box once the
> release is tagged (see below). Build and test each port on its own OS before
> relying on it or submitting upstream.

Both ports assume `PREFIX=/usr/local` (the default), because the scripts
reference `/usr/local/etc/blockor.conf` and `/usr/local/libexec/blockor/`.

## FreeBSD (`security/blockor`)

```
ports/freebsd/
├── Makefile
├── pkg-descr
└── files/
    └── blockord.in     # rc.d template; %%PREFIX%% is substituted
```
(The file list is inline in the Makefile via `PLIST_FILES`, so there is no
separate `pkg-plist`.)

Build and test:
```sh
# copy into a ports tree
mkdir -p /usr/ports/security/blockor
cp -R ports/freebsd/ /usr/ports/security/blockor/
cd /usr/ports/security/blockor

make makesum        # downloads the tarball and writes distinfo
make stage
make check-plist
make stage-qa
portlint -AC        # pkg install -y portlint, if needed
make package        # builds the .pkg
# ideally also build in a clean jail with poudriere
```

Submit upstream: open a PR on **FreeBSD Bugzilla** (product "Ports & Packages",
component "Individual Port(s)"). See the FreeBSD Porter's Handbook:
https://docs.freebsd.org/en/books/porters-handbook/

## OpenBSD (`security/blockor`)

```
ports/openbsd/
├── Makefile
└── pkg/
    ├── DESCR
    └── PLIST
```

Build and test:
```sh
mkdir -p /usr/ports/mystuff/security/blockor
cp -R ports/openbsd/ /usr/ports/mystuff/security/blockor/
cd /usr/ports/mystuff/security/blockor

make makesum        # writes distinfo
make
make fake           # stages into ${WRKINST}
make package
make plist          # helps verify/refresh PLIST
portcheck           # pkg_add portcheck, if needed
```

Compare against `security/sshguard` in the OpenBSD ports tree — it is the
closest existing port and the best reference for the `@rcscript`, `@sample`, and
man-page conventions, which differ from FreeBSD.

Submit upstream: send the port (as a tarball/diff) to **ports@openbsd.org** for
review. See `ports(7)` and https://www.openbsd.org/faq/ports/

## Generating distinfo

`make makesum` fetches the release distfile and records its checksum. It needs a
tagged release, so tag and push `v0.2.0` first:

```sh
git tag v0.2.0 && git push origin v0.2.0
```

Then run `make makesum` in each port directory on the respective OS.
