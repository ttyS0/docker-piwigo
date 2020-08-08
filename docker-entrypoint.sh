#!/bin/bash
set -e

for d in $(ls /usr/local/piwigo/template); do
  [ "$(ls -A /var/www/piwigo/${d})" ] || cp -R /usr/local/piwigo/template/${d}/* /var/www/piwigo/${d}/
  chown -R www-data /var/www/piwigo/${d}
done



exec apache2-foreground
