#!/bin/bash
dbname=db
dbnametest=testdb
domain=domain.tld
domaintest=test.domain.tld
www=WWW-PATH
path=$www/$domain
pathtest=$www/$domaintest
cd ~
mysqldump --complete-insert --routines --triggers --single-transaction $dbname > ~/$dbname.sql;
mysql -e "DROP DATABASE IF EXISTS $dbnametest;"
mysql -e "CREATE DATABASE $dbnametest;"
mysql -e "GRANT ALL PRIVILEGES ON $dbnametest.* to $dbnametest@localhost;"
mysql -e "FLUSH PRIVILEGES;"
mysql "$dbnametest" < ~/$dbname.sql
rm ~/$dbname.sql
mysql -e "UPDATE $dbnametest.wcf1_option SET optionValue='disk' WHERE optionName='cache_source_type';"
mysql -e "UPDATE $dbnametest.wcf1_application SET domainName='$domaintest',cookieDomain='$domaintest';"
mysql -e "UPDATE $dbnametest.wcf1_option SET optionValue='${dbnametest}_' WHERE optionName='cookie_prefix';"
cd $www
rsync -a --delete $domain/ $domaintest
sed -i "s/$dbname/$dbnametest/g" $pathtest/config.inc.php
if [ -f $pathtest/options.inc.php ]; then
	rm $pathtest/options.inc.php
fi
count=`ls -1 $pathtest/templates/compiled/*.php 2>/dev/null | wc -l`
if [ $count != 0 ]; then
	rm $pathtest/templates/compiled/*.php
fi
count=`ls -1 $pathtest/cache/*.php 2>/dev/null | wc -l`
if [ $count != 0 ]; then
	rm	 $pathtest/cache/*.php
fi
count=`ls -1 $pathtest/acp/templates/compiled/*.php  2>/dev/null | wc -l`
if [ $count != 0 ]; then
	rm $pathtest/acp/templates/compiled/*.php
fi
