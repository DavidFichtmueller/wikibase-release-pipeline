#!/bin/sh

export DOLLAR='$'
envsubst < /wikibase.conf.template > /wikibase.conf


if [ ! -f "/etc/nginx/conf.d/wikibase.conf" ]; then 
	cp /wikibase.conf /etc/nginx/conf.d/wikibase.conf	; 
fi
echo "server: $SERVER_NAME; domains: $LETS_ENCRYPT_DOMAINS ; e-mail: $LETS_ENCRYPT_EMAIL ; force renewal: $LETS_ENCRYPT_FORCE_RENEWAL ; "

# run let's encrypt, based on https://github.com/enonic-cloud/docker-apache2-letsencrypt/blob/master/launcher.sh

echo "----------------------------------------------------------------"
echo " Running $0 to check for letsencrypt certificate and renewal"
echo "--------------------------------------------------------------- -"
privateKeyHome="/etc/letsencrypt/live/$SERVER_NAME"
privateKeyFile="$privateKeyHome/privkey.pem"
renewalFlags=""
if [ ! -z $LETS_ENCRYPT_FORCE_RENEWAL ]; then
  renewalFlags="$renawalFlags --force-renewal"
fi

echo "Checking if certificate [$privateKeyFile] exist )."
if [ ! -f $privateKeyFile ]; then
  echo "Certificate file [$privateKeyFile] does not exist"
  
  if [[ ! "x$LETS_ENCRYPT_DOMAINS" == "x" ]]; then
    DOMAIN_CMD="-d $(echo $LETS_ENCRYPT_DOMAINS | sed 's/,/ -d /')"
    cmd="certbot -n certonly --no-self-upgrade --agree-tos --standalone -m \"$LETS_ENCRYPT_EMAIL\" -d $SERVER_NAME $DOMAIN_CMD"
    echo "Requesting certificates for [$cmd]"
    eval $cmd
  else
    echo "LETS_ENCRYPT_DOMAINS not defined, skipping certificate creation"
  fi
else
  echo "Certificate file [$privateKeyFile] exist, checking for renewal"
  cmd="certbot renew --no-random-sleep-on-renew --nginx --no-self-upgrade $renewalFlags"
  echo "Requesting certificate renawal: [$cmd]"
  eval $cmd
fi

if [ ! -e "/etc/letsencrypt/options-ssl-nginx.conf" ] || [ ! -e "/etc/letsencrypt/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/etc/letsencrypt/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/etc/letsencrypt/ssl-dhparams.pem"
  echo
fi

if [[ $(grep certbot /etc/crontabs/root | wc -l) == "0" ]]; then
  echo '42	23,5	*	*	*	certbot renew --nginx\n' >> /etc/crontabs/root
  echo "added certbot to crontab"
fi

echo "starting nginx"
nginx -g "daemon off;"



