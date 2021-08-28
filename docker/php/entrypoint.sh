#!/bin/bash

composer install --no-interaction --ignore-platform-reqs --optimize-autoloader
# --no-dev for prod

# Install Infection Mutantion Testing Framework
composer global require infection/infection

cp /root/.composer/vendor/bin/* /usr/local/bin/

php-fpm
