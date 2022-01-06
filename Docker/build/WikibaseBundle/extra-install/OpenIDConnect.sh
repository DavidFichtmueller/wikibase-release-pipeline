#!/bin/bash

# adjust a file according to 
# https://github.com/jumbojett/OpenID-Connect-PHP/pull/208/files
# Fix not included in the dependencies for OpenIDConnect for Mediawiki 1.35
sed -i "/unset(\$token_params\['client_secret'\]);/a \            unset(\$token_params['client_id']);" /var/www/html/extensions/OpenIDConnect/vendor/jumbojett/openid-connect-php/src/OpenIDConnectClient.php
