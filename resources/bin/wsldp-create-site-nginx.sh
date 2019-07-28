#!/bin/bash

# TODO cleanup

WSLDP_GLOBAL_CONFIG_DIR=
if [ -f $WSLDP_GLOBAL_CONFIG_DIR/defaults ]; then
    source $WSLDP_GLOBAL_CONFIG_DIR/defaults
else
    echo "$WSLDP_GLOBAL_CONFIG_DIR/defaults is missing. Aborting."
    exit
fi

checkPHPFPM () {
    if [ -f "/usr/sbin/php-fpm$1" ]; then
        return 0
    fi

    return -1
}

help () {
    echo "Error: missing required parameters."
    echo "Usage: "
    echo "  wsldp-create-site-nginx server_name root_dir http_port ssl_port php_fpm_version add_host_host_file params"
    echo "    server_name - address of the site"
    echo "    root_dir - root dir"
    echo "    http_port - port"
    echo "    ssl_port - SSL port (0 - disable)"
    echo "    php_fpm_version - PHP-FPM version"
    echo "    add_to_hosts_file - should the host be added to system hosts file (true|false). Default false."
    echo "    params"
}

checkIfAlreadyExists () {
    # check servername
    fgrep $1 /etc/nginx/sites-enabled/* > /dev/null 2>&1
    GOT_SITE=$?
    # check directory
    fgrep $2 /etc/nginx/sites-enabled/* > /dev/null 2>&1
    GOT_DIR=$?

    if [ "$GOT_SITE" == "0" ]; then
        if [ "$GOT_DIR" == "0" ]; then
            echo "Site $1 already configured (root dir: $2)"
            exit -1
        fi
    fi

    return 0
}

if [ "$#" -lt 5 ]; then
    help
    exit -1
fi

SERVER_NAME=$1
ROOT_DIR=$2
HTTP_PORT=$3
HTTP_SSL_PORT=$4
PHP_FPM_VER=$5
ADD_TO_HOSTS=$6
PARAMS=$7

checkPHPFPM $PHP_FPM_VER
if [ "$?" != "0" ]; then
    echo "Missing requested $PHP_FPM_VER php-fpm. Aborting."
    exit -1
fi

if [ -d "$ROOT_DIR" ]; then
    CWD=$(pwd)
    cd $ROOT_DIR
    ROOT_DIR=$(pwd -P)
    cd $CWD

    checkIfAlreadyExists $SERVER_NAME $ROOT_DIR

    # TODO
    declare -A params=$6       # Create an associative array
    declare -A headers=${10}   # Create an associative array
    declare -A rewrites=${11}  # Create an associative array
    paramsTXT=""
    if [ -n "$7" ]; then
        for element in "${!params[@]}"
        do
            paramsTXT="${paramsTXT}
            fastcgi_param ${element} ${params[$element]};"
        done
    fi
    headersTXT=""
    if [ -n "${10}" ]; then
        for element in "${!headers[@]}"
        do
            headersTXT="${headersTXT}
            add_header ${element} ${headers[$element]};"
        done
    fi
    rewritesTXT=""
    if [ -n "${11}" ]; then
        for element in "${!rewrites[@]}"
        do
            rewritesTXT="${rewritesTXT}
            location ~ ${element} { if (!-f \$request_filename) { return 301 ${rewrites[$element]}; } }"
        done
    fi

     if [ "$HTTP_SSL_PORT" != "0" ]; then
        LISTEN_SSL="listen $HTTP_SSL_PORT ssl http2;"
        SSL_CERTIFICATE="ssl_certificate     /etc/nginx/ssl/$SERVER_NAME.crt;"
        SSL_CERTIFICATE_KEY="ssl_certificate_key /etc/nginx/ssl/$SERVER_NAME.key;"
    fi

    block="server {
        listen $HTTP_PORT;
        $LISTEN_SSL
        # listen $HTTP_SSL_PORT ssl http2;
        # listen ${HTTP_PORT:-80};
        # listen ${HTTP_SSL_PORT:-443} ssl http2;
        server_name $SERVER_NAME;
        root \"$ROOT_DIR\";

        index index.html index.htm index.php;

        charset utf-8;

        $rewritesTXT

        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
            $headersTXT
        }

        #$configureZray
        #$configureXhgui

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        access_log off;
        error_log  /var/log/nginx/$SERVER_NAME-error.log error;

        sendfile off;

        client_max_body_size 100m;

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php$PHP_FPM_VER-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            $paramsTXT

            fastcgi_buffering off; # This must be here for WSL as of 11/28/2018
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
        }

        location ~ /\.ht {
            deny all;
        }

        $SSL_CERTIFICATE
        $SSL_CERTIFICATE_KEY
        }
    "
    echo "$block" > "/etc/nginx/sites-available/$SERVER_NAME"
    if [ "$RUNNING_ON" != "wsl" ]; then
        sed -i "s|fastcgi_buffering|#fastcgi_buffering|" /etc/nginx/sites-available/$SERVER_NAME
    fi
    ln -fs "/etc/nginx/sites-available/$SERVER_NAME" "/etc/nginx/sites-enabled/$SERVER_NAME" 2> /dev/null

    if [ "$ADD_TO_HOSTS" == "true" ]; then
        sudo $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh "$LOCAL_IP_ADDRESS" "$SERVER_NAME"
    fi

    echo "Done. Restart NGINX and all it need to handle this site"
else 
    echo "Aborted ($ROOT_DIR doesn't exist)."
    exit -1
fi
