### CLI ###

FROM ubuntu:jammy AS cli

# Fixes some weird terminal issues such as broken clear / CTRL+L
ENV TERM=linux

# Ensure apt doesn't ask questions when installing stuff
ENV DEBIAN_FRONTEND=noninteractive

# Install Ondrej repos for Ubuntu jammy, PHP, composer and selected extensions - better selection than
# the distro's packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        unzip \
        php8.3-apcu \
        php8.3-cli \
        php8.3-curl \
        php8.3-mbstring \
        php8.3-opcache \
        php8.3-readline \
        php8.3-xml \
        php8.3-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

CMD ["php", "-a"]

### FPM ###

FROM cli AS fpm

# Install FPM
RUN apt-get update \
    && apt-get -y --no-install-recommends install php8.3-fpm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

STOPSIGNAL SIGQUIT

# PHP-FPM packages need a nudge to make them docker-friendly
COPY overrides.conf /etc/php/8.3/fpm/pool.d/z-overrides.conf

CMD ["/usr/sbin/php-fpm8.3", "-O" ]

# Open up fcgi port
EXPOSE 9000
