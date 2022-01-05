FROM nginx:1.15-alpine

RUN apk add certbot certbot-nginx curl

COPY wikibase.conf.template /wikibase.conf.template
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


CMD ["-D", "FOREGROUND"]