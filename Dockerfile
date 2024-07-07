# Unofficial fivefilters Full-Text RSS service
# Enriches third-party RSS feeds with full text articles
# https://bitbucket.org/fivefilters/full-text-rss

FROM	alpine/git AS gitsrc
WORKDIR /ftr
RUN	git clone https://bitbucket.org/fivefilters/full-text-rss.git . && \
        git reset --hard

FROM	alpine/git AS gitconfig
WORKDIR	/ftr-site-config
RUN	git clone https://github.com/fivefilters/ftr-site-config . 

# Do not upgrade. More recent versions of PHP are seg faulting. 
FROM	php:5-apache

# https://unix.stackexchange.com/questions/371890/debian-the-repository-does-not-have-a-release-file#answer-743863
RUN 	echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list

RUN   apt-get update && \
      apt-get -y install --no-install-recommends \
      libtidy-dev \
      && rm -rf /var/lib/apt/lists/*

RUN		docker-php-ext-install tidy

COPY php.ini /usr/local/etc/php/

COPY --from=gitsrc /ftr /var/www/html

# Instead of copying, we'll create the directory
RUN mkdir -p /var/www/html/site_config/standard

RUN		mkdir -p /var/www/html/cache/rss && \
            chmod -Rv 777 /var/www/html/cache && \
            chmod -Rv 777 /var/www/html/site_config

VOLUME	/var/www/html/cache
VOLUME  /var/www/html/site_config/standard

COPY	custom_config.php /var/www/html/

