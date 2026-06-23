# OpenBSD port for blockor.
#
# NOTE: this is a starting point. Validate it against a real OpenBSD ports tree
# (bsd.port.mk) and compare with security/sshguard, the closest existing port,
# especially for the rc.d (@rcscript) and man-page conventions.

COMMENT =	lightweight brute-force blocker built on PF

GH_ACCOUNT =	muktadiur
GH_PROJECT =	blockor
GH_TAGNAME =	v0.2.0
DISTNAME =	blockor-0.2.0

CATEGORIES =	security

HOMEPAGE =	https://github.com/muktadiur/blockor
MAINTAINER =	Muktadiur Rahman <muktadiur@gmail.com>

# BSD 3-clause
PERMIT_PACKAGE =	Yes

NO_BUILD =	Yes
NO_TEST =	Yes

RCDIR =		/etc/rc.d

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/usr/local/bin/blockor \
		${PREFIX}/bin/blockor
	${INSTALL_DATA_DIR} ${PREFIX}/libexec/blockor
	${INSTALL_SCRIPT} ${WRKSRC}/usr/local/libexec/blockor/blockord.sh \
		${PREFIX}/libexec/blockor/blockord.sh
	${INSTALL_DATA} ${WRKSRC}/usr/local/libexec/blockor/blockor.subr \
		${PREFIX}/libexec/blockor/blockor.subr
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/blockor
	${INSTALL_DATA} ${WRKSRC}/openbsd/usr/local/etc/blockor.conf \
		${PREFIX}/share/examples/blockor/blockor.conf
	${INSTALL_SCRIPT} ${WRKSRC}/openbsd/etc/rc.d/blockord \
		${RCDIR}/blockord
	${INSTALL_DATA_DIR} ${PREFIX}/man/man8
	gzip -dc ${WRKSRC}/openbsd/usr/local/man/man8/blockor.8.gz \
		> ${WRKDIR}/blockor.8
	${INSTALL_MAN} ${WRKDIR}/blockor.8 ${PREFIX}/man/man8/blockor.8

.include <bsd.port.mk>
