# Unofficial fivefilters Full-Text RSS service
# Enriches third-party RSS feeds with full text articles
# https://bitbucket.org/fivefilters/full-text-rss

FROM	heussd/git as gitsrc
WORKDIR /ftr
RUN	git clone https://git.sira.ai/ali2kan/fulltextrss.git . && \
		git reset --hard 384d52fd83361ffd6e7f28bd39b322970a015a28


FROM	heussd/git as gitconfig
WORKDIR	/ftr-site-config
RUN	git clone https://git.sira.ai/ali2kan/fulltextrss/src/branch/main/site_config/standard . 


FROM	php:5-apache

RUN   apt-get update && \
      apt-get -y install --no-install-recommends \
      libtidy-dev \
      && rm -rf /var/lib/apt/lists/*

RUN		docker-php-ext-install tidy

COPY --from=gitsrc /ftr /var/www/html
COPY --from=gitconfig /ftr-site-config/.* /ftr-site-config/* /var/www/html/site_config/standard/

RUN		mkdir -p /var/www/html/cache/rss && \
			chmod -Rv 777 /var/www/html/cache && \
			chmod -Rv 777 /var/www/html/site_config

VOLUME	/var/www/html/cache

COPY	custom_config.php /var/www/html/

