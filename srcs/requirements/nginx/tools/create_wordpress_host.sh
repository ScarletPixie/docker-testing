#!/bin/sh

mkdir -p /etc/nginx/ssl/
cd /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -subj "/C=BR/ST=Rio de Janeiro/L=Rio de Janeiro/O=Organization/OU=Department/CN=localhost"
mkdir /etc/nginx/ssl
chown -R root:root /etc/nginx/ssl
chmod -R 600 /etc/nginx/ssl

cat << 'EOF' > '/etc/nginx/http.d/wordpress.conf'
server {
        listen          443 ssl default_server;
        index           index.html index.php index.htm;
        server_name     localhost;
        root            /var/www/html/wordpress;


        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;

        location / {
                try_files $uri $uri/ /index.php?$args;
        }
        location ~ \.php$ {
                fastcgi_split_path_info ^(.+?\.php)(/.*)$;
                include fastcgi_params;
                fastcgi_pass    inception_wordpress:9000;
                fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
        location ~ /\.ht {
                deny all;
        }
}
EOF