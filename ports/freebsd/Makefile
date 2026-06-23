# Created by: Muktadiur Rahman <muktadiur@gmail.com>

PORTNAME=	blockor
DISTVERSIONPREFIX=	v
DISTVERSION=	0.2.0
CATEGORIES=	security

MAINTAINER=	muktadiur@gmail.com
COMMENT=	Lightweight brute-force blocker built on PF
WWW=		https://github.com/muktadiur/blockor

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USE_GITHUB=	yes
GH_ACCOUNT=	muktadiur

USE_RC_SUBR=	blockord

NO_ARCH=	yes
NO_BUILD=	yes

# The scripts assume PREFIX=/usr/local (the default) for the locations of
# blockor.conf and blockor.subr.
PLIST_FILES=	bin/blockor \
		libexec/blockor/blockord.sh \
		libexec/blockor/blockor.subr \
		"@sample etc/blockor.conf.sample" \
		share/man/man8/blockor.8.gz

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/usr/local/bin/blockor \
		${STAGEDIR}${PREFIX}/bin/blockor
	@${MKDIR} ${STAGEDIR}${PREFIX}/libexec/blockor
	${INSTALL_SCRIPT} ${WRKSRC}/usr/local/libexec/blockor/blockord.sh \
		${STAGEDIR}${PREFIX}/libexec/blockor/blockord.sh
	${INSTALL_DATA} ${WRKSRC}/usr/local/libexec/blockor/blockor.subr \
		${STAGEDIR}${PREFIX}/libexec/blockor/blockor.subr
	${INSTALL_DATA} ${WRKSRC}/freebsd/usr/local/etc/blockor.conf \
		${STAGEDIR}${PREFIX}/etc/blockor.conf.sample
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/man/man8
	gzip -dc ${WRKSRC}/freebsd/usr/local/man/man8/blockor.8.gz > \
		${STAGEDIR}${PREFIX}/share/man/man8/blockor.8

.include <bsd.port.mk>
