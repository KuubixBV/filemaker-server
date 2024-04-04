FROM amd64/ubuntu:22.04

# Hello world
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
        firewalld                       \
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
        wget                            \
        zlib1g
 
# install user management
RUN DEBIAN_FRONTEND=noninteractive      \
    apt install                      -y \
        init

# Install packages for headless Google Chrome
RUN apt-get update && apt-get install -y \
    xvfb \
    libxi6 \
    libgconf-2-4

# Install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -y ./google-chrome-stable_current_amd64.deb || apt-get install -f -y

# Install ChromeDriver
RUN apt-get update && apt-get install -y \
    chromium-chromedriver

# Install python dep
RUN pip install selenium && pip install python-dotenv

# clean up installations
RUN DEBIAN_FRONTEND=noninteractive      \
    apt --fix-broken install         -y
RUN DEBIAN_FRONTEND=noninteractive      \
    apt autoremove                   -y
RUN DEBIAN_FRONTEND=noninteractive      \
    apt clean                        -y
 
# document the ports that should be
# published when filemaker server
# is installed
EXPOSE 80
EXPOSE 443
EXPOSE 2399
EXPOSE 5003
EXPOSE 4444

ARG VERSION
RUN echo $VERSION

# when containers run, start this
# command as root to initialize
# user management
USER root
CMD ["/sbin/init"]