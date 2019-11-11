FROM php:5.6-apache

# Use the default development configuration
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

ADD ssl/ssl-cert-snakeoil.pem /etc/ssl/certs/
ADD ssl/ssl-cert-snakeoil.key /etc/ssl/private/

# install the PHP extensions we need
RUN set -eux; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
		a2enmod ssl; \
		a2ensite default-ssl.conf; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		vim \
		mysql-client \
		wget \
		git \
		iputils-ping \
		libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libzip-dev \
		libxml2-dev \
		libmcrypt-dev \
		libcurl4-gnutls-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype-dir=/usr \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		pdo_mysql \
		dom \
		simplexml \
		iconv \
		mcrypt \
		curl \
		hash \
		soap \
		gd \
		zip \
	; \
	pecl install xdebug-2.5.5; \
	\
	docker-php-ext-enable xdebug;

# set recommended PHP.ini settings
RUN { \
		echo "zend_extension=$(find /usr/local/lib/php/extensions -name xdebug.so)"; \
		echo "xdebug.remote_enable=1"; \
		echo "xdebug.remote_port=9000"; \
		echo "xdebug.remote_connect_back=0"; \
		echo "xdebug.remote_host=host.docker.internal"; \
		echo "xdebug.idekey=PHPSTORM"; \
		echo "xdebug.max_nesting_level=1000"; \
	} > $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini; \
	chmod 666 $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini;

# set recommended my.cnf settings
RUN { \
		echo '[client]'; \
		echo 'host="db"'; \
		echo 'user="root"'; \
		echo 'password="secret"'; \
		echo 'pager="less"'; \
	} >> /etc/mysql/my.cnf;

# n98-magerun https://magerun.net/
RUN curl -o /usr/local/bin/n98-magerun https://files.magerun.net/n98-magerun.phar; \
	chmod +x /usr/local/bin//n98-magerun;

WORKDIR /var/www/html