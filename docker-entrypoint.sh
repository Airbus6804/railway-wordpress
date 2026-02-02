#!/bin/bash

set -e

# Ensure Apache uses mpm_prefork (required for mod_php)
a2dismod mpm_event 2>/dev/null || true
a2dismod mpm_worker 2>/dev/null || true
a2dismod mpm_prefork 2>/dev/null || true
a2enmod mpm_prefork

# Delegate to the original WordPress entrypoint, which will
# populate /var/www/html from /usr/src/wordpress and then
# start Apache in the foreground.
exec docker-entrypoint-original.sh apache2-foreground
