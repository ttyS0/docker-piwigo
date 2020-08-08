#!/bin/bash
set -e

for d in $(ls /usr/local/piwigo/template); do
  [ "$(ls -A /var/www/${d})" ] || cp -R /usr/local/piwigo/template/${d}/* /var/www/${d}/
done


exec apache2-foreground
