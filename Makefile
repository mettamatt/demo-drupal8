packages:
	apt-get update
	apt-get install -y mysql-client rsync
	curl -L "https://github.com/drush-ops/drush/releases/download/8.1.15/drush.phar" > /usr/local/bin/drush
	chmod +x /usr/local/bin/drush

drupalconfig:
	cp /var/www/html/sites/default/tugboat.settings.php /var/www/html/sites/default/settings.local.php

createdb:
	mysql -h mysql -u tugboat -ptugboat -e "create database demo;"

importdb:
	curl -L "https://www.dropbox.com/s/ji41n0q14qgky9a/demo-drupal8-database.sql.gz?dl=0" > /tmp/database.sql.gz
	zcat /tmp/database.sql.gz | mysql -h mysql -u tugboat -ptugboat demo

importfiles:
	curl -L "https://www.dropbox.com/s/jveuu586eb49kho/demo-drupal8-files.tar.gz?dl=0" > /tmp/files.tar.gz
	tar -C /tmp -zxf /tmp/files.tar.gz
	rsync -av --delete /tmp/files/ /var/www/html/sites/default/files/

build:
	drush -r /var/www/html cache-rebuild

cleanup:
	apt-get clean
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

tugboat-init: packages createdb drupalconfig importdb importfiles build cleanup
tugboat-update: importdb importfiles build cleanup
tugboat-build: build