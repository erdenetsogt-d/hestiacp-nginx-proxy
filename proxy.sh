#!/bin/bash
read -p "Enter port number: " port_number
read -p "Enter template name: " tname
f1=$tname.tpl
f2=$tname.stpl
pn="3000"

cat <<EOT >> $f1
#=========================================================================#
# This template modified by erdee proxy script                            #
#=========================================================================#

server {
    listen      %ip%:%web_port%;
    server_name %domain_idn% %alias_idn%;
    root        %docroot%;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;

    include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

   location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location ~ /\.(?!well-known\/) {
       deny all;
       return 404;
    }

    location /vstats/ {
        alias   %home%/%user%/web/%domain%/stats/;
        include %home%/%user%/web/%domain%/stats/auth.conf*;
    }

    include     /etc/nginx/conf.d/phpmyadmin.inc*;
    include     /etc/nginx/conf.d/phppgadmin.inc*;
    include     %home%/%user%/conf/web/%domain%/nginx.conf_*;
}

EOT

cat <<EOT >> $f2
#=========================================================================#
# This template modified by erdee proxy script                            #
#=========================================================================#

server {
    listen      %ip%:%web_ssl_port% ssl http2;
    server_name %domain_idn% %alias_idn%;
    root        %sdocroot%;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;

    ssl_certificate      %ssl_pem%;
    ssl_certificate_key  %ssl_key%;
    ssl_stapling on;
    ssl_stapling_verify on;

    include %home%/%user%/conf/web/%domain%/nginx.hsts.conf*;

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location ~ /\.(?!well-known\/) {
       deny all;
       return 404;
    }

    location /vstats/ {
        alias   %home%/%user%/web/%domain%/stats/;
        include %home%/%user%/web/%domain%/stats/auth.conf*;
    }

    proxy_hide_header Upgrade;

    include     /etc/nginx/conf.d/phpmyadmin.inc*;
    include     /etc/nginx/conf.d/phppgadmin.inc*;
    include     %home%/%user%/conf/web/%domain%/nginx.ssl.conf_*;
}

EOT

if [[ $pn != "" && $port_number != "" ]]; then
sed -i "s/$pn/$port_number/" $f1
sed -i "s/$pn/$port_number/" $f2
echo "Template creation done."
fi

sudo mv $tname.* /usr/local/hestia/data/templates/web/nginx/php-fpm
echo "Moving Done."

