FROM amd64/ubuntu:22.04
ENV TZ="Europe/Brussels"

# update all software download sources
RUN DEBIAN_FRONTEND=noninteractive      \
    apt update

# upgrade all installed software
# packages
RUN DEBIAN_FRONTEND=noninteractive      \
    apt full-upgrade                 -y

# install filemaker server dependencies
RUN DEBIAN_FRONTEND=noninteractive      \
    apt install                      -y \
    acl                             \
    apache2-bin                     \
    apache2-utils                   \
    avahi-daemon                    \
    curl                            \
    fonts-baekmuk                   \
    fonts-liberation2               \
    fonts-noto                      \
    fonts-takao                     \
    fonts-wqy-zenhei                \
    libaio1                         \
    libantlr3c-3.4-0                \
    libavahi-client3                \
    libbz2-1.0                      \
    libc++1-12                      \
    libcurl3-gnutls                 \
    libcurl4-gnutls-dev             \
    libcurl4                        \
    libdjvulibre21                  \
    libetpan20                      \
    libevent-2.1-7                  \
    libexpat1                       \
    libfontconfig1                  \
    libfreetype6                    \
    libgomp1                        \
    libheif1                        \
    libjpeg-turbo8                  \
    liblqr-1-0                      \
    liblzma5                        \
    libodbc1                        \
    libomniorb4-2                   \
    libomp5-12                      \
    libpam0g                        \
    libpng16-16                     \
    libsasl2-2                      \
    libtiff5                        \
    libuuid1                        \
    libwebpdemux2                   \
    libwebpmux3                     \
    libxml2                         \
    libxpm4                         \
    libxslt1.1                      \
    lsb-release                     \
    logrotate                       \
    nginx                           \
    odbcinst1debian2                \
    openjdk-11-jre                  \
    openssl                         \
    policycoreutils                 \
    sysstat                         \
    unzip                           \
    zip                             \
    git                             \
    nano                            \
    vim                             \
    python3-pip                     \
    wget                            \
    gnupg2                          \
    software-properties-common      \
    zlib1g

# install user management
RUN DEBIAN_FRONTEND=noninteractive      \
    apt install                      -y \
    init

# install php and apache for the jdbc-api
RUN DEBIAN_FRONTEND=noninteractive      \
    apt install                      -y \
    apache2

RUN DEBIAN_FRONTEND=noninteractive      \
    add-apt-repository ppa:ondrej/php

RUN DEBIAN_FRONTEND=noninteractive      \
    apt install                     -y  \
    php8.2                              \
    php8.2-cli                          \
    php8.2-bz2                          \
    php8.2-curl                         \
    php8.2-mbstring                     \
    php8.2-intl                         \
    php8.2-xml                          \
    php8.2-dom                          \
    php8.2-intl                         \
    libapache2-mod-php8.2 &&            \
    rm -rf /var/lib/apt/lists/*

# install packages for headless Google Chrome
RUN apt update && apt install -y        \
    xvfb                                \
    libxi6                              \
    libgconf-2-4

# install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -y ./google-chrome-stable_current_amd64.deb || apt-get install -f -y

# install Chrome Driver
RUN apt install chromium-chromedriver -y

# install python dep
RUN pip install selenium && pip install python-dotenv

# Installing net tools for killing process java
RUN apt install -y                      \
    lsof                                \
    net-tools

# install composer for building japi
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer &&         \
    chmod +x /usr/local/bin/composer

# clean up installations
RUN DEBIAN_FRONTEND=noninteractive      \
    apt --fix-broken install         -y
RUN DEBIAN_FRONTEND=noninteractive      \
    apt autoremove                   -y
RUN DEBIAN_FRONTEND=noninteractive      \
    apt clean                        -y

# ports to expose
EXPOSE 80
EXPOSE 443
EXPOSE 2399
EXPOSE 5003
EXPOSE 4444
EXPOSE 32582
EXPOSE 10073

# Code to make the docker image unique depening on the version
ARG VERSION
RUN echo $VERSION
USER root
CMD ["/sbin/init"]