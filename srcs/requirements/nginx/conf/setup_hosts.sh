#!/bin/sh

set -e

#	check if all envs are present
WP_CERT="$1"
WP_CERT_KEY="$2"

test -n "$DOMAIN_NAME" || (echo "DOMAIN_NAME not set" && false);
test -n "$WP_CERT" || (echo "Empty certificate (crt file)" && false);
test -n "$WP_CERT_KEY" || (echo "Empty certificate (key file)" && false);


#	place ssl certificate
cd /etc/nginx/ssl
echo "$WP_CERT" > "$DOMAIN_NAME".crt
echo "$WP_CERT_KEY" > "$DOMAIN_NAME".key

chown -R www-data:www-data /etc/nginx/ssl
chmod -R 700 /etc/nginx/ssl


#	create wordpress host
cat << EOF > '/etc/nginx/http.d/wordpress.conf'
server {
	listen	443 ssl default_server;
	index		index.html index.php index.htm;
	server_name	$DOMAIN_NAME;
	root		/var/www/html/wordpress;

	ssl_certificate /etc/nginx/ssl/$DOMAIN_NAME.crt;
	ssl_certificate_key /etc/nginx/ssl/$DOMAIN_NAME.key;
	ssl_protocols TLSv$TLS_VER;
	ssl_prefer_server_ciphers on;

	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}
		location ~ \.php$ {
		fastcgi_split_path_info ^(.+?\.php)(/.*)$;
		include fastcgi_params;
		fastcgi_pass    inception_wordpress:9000;
		fastcgi_param   SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	}
		location ~ /\.ht {
		deny all;
	}
}
EOF


#	setup nginx conf
#		remove tlsv1 from default setting in nginx and remove default nginx page
sed -i "/ssl_protocols.*/c\ssl_protocols TLSv$TLS_VER;" '/etc/nginx/nginx.conf'
rm -f /etc/nginx/http.d/default.conf
#		delete user line
sed -i '/user nginx/d' /etc/nginx/nginx.conf

trap "rm -f $0" EXIT