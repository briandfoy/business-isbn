USER=comdog
SERVER=shell.sourceforge.net
PROJECT=perl-isbn

SCP=/usr/bin/scp
PERL=/usr/bin/perl

FIRST=`${PERL} -e "print substr(shift, 0, 1)" ${PROJECT}`
SECOND=`${PERL} -e "print substr(shift, 0, 2)" ${PROJECT}`
PATH=/home/groups/${FIRST}/${SECOND}/${PROJECT}/htdocs

install: index.html barcode.png
	${SCP} index.html ${USER}@${SERVER}:${PATH}
	${SCP} barcode.png ${USER}@${SERVER}:${PATH}
	@touch $@

clean:
	@ rm -rf install
