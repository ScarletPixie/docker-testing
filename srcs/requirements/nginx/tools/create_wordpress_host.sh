#!/bin/sh

set -e

WP_CERT="$1"
WP_CERT_KEY="$2"

#    check if all envs are present
test -n "$DOMAIN_NAME" || (echo "DOMAIN_NAME not set" && false);
test -n "$WP_CERT" || (echo "Empty certificate (crt file)" && false);
test -n "$WP_CERT_KEY" || (echo "Empty certificate (key file)" && false);

cd /etc/nginx/ssl

echo "$WP_CERT" > "$DOMAIN_NAME".crt
echo "$WP_CERT_KEY" > "$DOMAIN_NAME".key

chown -R www-data:www-data /etc/nginx/ssl
chmod -R 700 /etc/nginx/ssl

cat << EOF > '/etc/nginx/http.d/wordpress.conf'
server {
        listen          443 ssl default_server;
        index           index.html index.php index.htm;
        server_name     $DOMAIN_NAME;
        root            /var/www/html/wordpress;

        ssl_certificate /etc/nginx/ssl/$DOMAIN_NAME.crt;
        ssl_certificate_key /etc/nginx/ssl/$DOMAIN_NAME.key;
        ssl_protocols TLSv1.2;
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