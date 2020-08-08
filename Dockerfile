FROM php:7.4.8-apache-buster AS base

ENV PIWIGO_VERSION=2.10.2 \
    PIWIGO_HOME="/var/www/piwigo"

RUN apt-get -yqq update \
    && apt-get install -yq --no-install-recommends \
        fonts-freefont-ttf \
        curl \
        libtidy5deb1 \
        libpng-tools \
        libmcrypt4 \
        libjpeg62-turbo \
        libfreetype6 \
        libzip4 \
        dcraw \
        mediainfo \
        ffmpeg \
        imagemagick \
        unzip \
        exiftool \
        libonig5 \
    && apt-get autoremove -y \
    && apt-get clean -y

FROM base AS build

RUN apt-get -yqq update \
    && apt-get install -y --no-install-recommends \
        git \
        zlib1g-dev \
        libzip-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libtidy-dev \
        libxml2-dev \
        libmagickwand-dev \
        libcurl4-gnutls-dev \
        libonig-dev \
        fontconfig \
        tar \
   && docker-php-ext-install dom pdo pdo_mysql mysqli zip tidy gd curl mbstring xml exif \
   && pecl install imagick \
   && docker-php-ext-enable imagick \
   && curl -SL -o piwigo.zip http://piwigo.org/download/dlcounter.php?code=${PIWIGO_VERSION} \
   && mkdir -p ${PIWIGO_HOME} /usr/local/piwigo/template \
   && unzip piwigo.zip -d /var/www \
   && cd ${PIWIGO_HOME} \
   && mv galleries themes plugins local /usr/local/piwigo/template/ \
   && grep -Rn MyISAM install | cut -d: -f1 | sort -u | while read file; do sed -i 's/MyISAM/InnoDB/' "${file}"; done \
   && chown -R www-data:www-data ${PIWIGO_HOME}

FROM base AS release

COPY --from=build /usr/local /usr/local/
COPY --from=build --chown=33:33 /var/www /var/www/

COPY php.ini /usr/local/etc/php/php.ini
COPY piwigo-vhost-conf /etc/apache2/sites-enabled/piwigo.conf
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh

RUN a2enmod rewrite \
   && rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/apache2/sites-enabled/000-*.conf /usr/src \
   && chmod a+x /bin/docker-entrypoint.sh

WORKDIR ${PIWIGO_HOME}

EXPOSE 80

VOLUME ["${PIWIGO_HOME}/galleries","${PIWIGO_HOME}/local","${PIWIGO_HOME}/plugins","${PIWIGO_HOME}/themes","/config"]

ENTRYPOINT ["/bin/docker-entrypoint.sh"]

