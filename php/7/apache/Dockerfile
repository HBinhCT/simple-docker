FROM php:7-apache

# Use default development configuration
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ssl/ /etc/ssl/

# !!!
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)";

# Install the necessary packages
RUN apt-get update; \
	apt-get install -y --no-install-recommends \
		vim \
		curl \
		wget \
		git \
		unzip \
		iputils-ping \
	;

# see https://secure.php.net/manual/en/opcache.installation.php
RUN docker-php-ext-install -j "$(nproc)" opcache; \
    { \
		echo "opcache.memory_consumption=128"; \
		echo "opcache.interned_strings_buffer=8"; \
		echo "opcache.max_accelerated_files=4000"; \
		echo "opcache.revalidate_freq=60"; \
		echo "opcache.fast_shutdown=1"; \
	} > $PHP_INI_DIR/conf.d/docker-php-ext-opcache-recommended.ini

# Install Xdebug (PHP 7)
RUN pecl install xdebug; \
	# docker-php-ext-enable xdebug; \
	{ \
		echo "zend_extension=$(find /usr/local/lib/php/extensions -name xdebug.so)"; \
		echo "xdebug.remote_enable=1"; \
		echo "xdebug.remote_port=9000"; \
		echo "xdebug.remote_connect_back=0"; \
		echo "xdebug.remote_host=host.docker.internal"; \
		echo "xdebug.idekey=PHPSTORM"; \
		echo "xdebug.max_nesting_level=1000"; \
	} > $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini; \
	chmod 666 $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini;

# Enable apache rewrite and ssl
RUN if command -v a2enmod; then \
		a2enmod rewrite; \
		a2enmod ssl; \
		a2ensite default-ssl.conf; \
	fi;
	
# Some else

# !!!
WORKDIR /var/www/html
