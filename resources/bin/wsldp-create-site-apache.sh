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
    echo "  wsldp-create-site-apache server_name root_dir http_port ssl_port php_fpm_version add_host_host_file params"
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
    fgrep $1 /etc/apache2/sites-enabled/* > /dev/null 2>&1
    GOT_SITE=$?
    # check directory
    fgrep $2 /etc/apache2/sites-enabled/* > /dev/null 2>&1
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
    declare -A params=$6     # Create an associative array
    declare -A headers=${10}      # Create an associative array
    paramsTXT=""
    if [ -n "$6" ]; then
        for element in "${!params[@]}"
        do
            paramsTXT="${paramsTXT}
            SetEnv ${element} \"${params[$element]}\""
        done
    fi
    headersTXT=""
    if [ -n "${10}" ]; then
    for element in "${!headers[@]}"
    do
        headersTXT="${headersTXT}
        Header always set ${element} \"${headers[$element]}\""
    done
    fi

    block="<VirtualHost *:$HTTP_PORT>
        ServerAdmin webmaster@localhost
        ServerName $SERVER_NAME
        ServerAlias www.$SERVER_NAME
        DocumentRoot "$ROOT_DIR"
        $paramsTXT
        $headersTXT

        <Directory "$ROOT_DIR">
            AllowOverride All
            Require all granted
        </Directory>
        <IfModule mod_fastcgi.c>
            AddHandler php"$PHP_FPM_VER"-fcgi .php
            Action php"$PHP_FPM_VER"-fcgi /php"$PHP_FPM_VER"-fcgi
            Alias /php"$PHP_FPM_VER"-fcgi /usr/lib/cgi-bin/php"$PHP_FPM_VER"
            FastCgiExternalServer /usr/lib/cgi-bin/php"$PHP_FPM_VER" -socket /var/run/php/php"$PHP_FPM_VER"-fpm.sock -pass-header Authorization
        </IfModule>
        <IfModule !mod_fastcgi.c>
            <IfModule mod_proxy_fcgi.c>
                <FilesMatch \".+\.ph(ar|p|tml)$\">
                    SetHandler \"proxy:unix:/var/run/php/php"$PHP_FPM_VER"-fpm.sock|fcgi://localhost\"
                </FilesMatch>
            </IfModule>
        </IfModule>
        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/$SERVER_NAME-error.log
        CustomLog \${APACHE_LOG_DIR}/$SERVER_NAME-access.log combined

        #Include conf-available/serve-cgi-bin.conf
    </VirtualHost>

    # vim: syntax=apache ts=4 sw=4 sts=4 sr noet
    "
    echo "$block" > "/etc/apache2/sites-available/$SERVER_NAME.conf"
    ln -fs "/etc/apache2/sites-available/$SERVER_NAME.conf" "/etc/apache2/sites-enabled/$SERVER_NAME.conf"

    if [ "$HTTP_SSL_PORT" != "0" ]; then
        blockssl="<IfModule mod_ssl.c>
            <VirtualHost *:$HTTP_SSL_PORT>

                ServerAdmin webmaster@localhost
                ServerName $SERVER_NAME
                ServerAlias www.$SERVER_NAME
                DocumentRoot "$ROOT_DIR"
                $paramsTXT

                <Directory "$ROOT_DIR">
                    AllowOverride All
                    Require all granted
                </Directory>

                #LogLevel info ssl:warn

                ErrorLog \${APACHE_LOG_DIR}/$SERVER_NAME-error.log
                CustomLog \${APACHE_LOG_DIR}/$SERVER_NAME-access.log combined

                #Include conf-available/serve-cgi-bin.conf

                #   SSL Engine Switch:
                #   Enable/Disable SSL for this virtual host.
                SSLEngine on
                SSLCertificateFile      /etc/apache2/ssl/$SERVER_NAME.crt
                SSLCertificateKeyFile   /etc/apache2/ssl/$SERVER_NAME.key
                #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt
                #SSLCACertificatePath /etc/ssl/certs/
                #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt
                #SSLCARevocationPath /etc/apache2/ssl.crl/
                #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl

                #SSLVerifyClient require
                #SSLVerifyDepth  10

                <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
                    SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                    SSLOptions +StdEnvVars
                </Directory>

                <IfModule mod_fastcgi.c>
                    AddHandler php"$PHP_FPM_VER"-fcgi .php
                    Action php"$PHP_FPM_VER"-fcgi /php"$PHP_FPM_VER"-fcgi
                    Alias /php"$PHP_FPM_VER"-fcgi /usr/lib/cgi-bin/php"$PHP_FPM_VER"
                    FastCgiExternalServer /usr/lib/cgi-bin/php"$PHP_FPM_VER" -socket /var/run/php/php"$PHP_FPM_VER"-fpm.sock -pass-header Authorization
                </IfModule>
                <IfModule !mod_fastcgi.c>
                    <IfModule mod_proxy_fcgi.c>
                        <FilesMatch \".+\.ph(ar|p|tml)$\">
                            SetHandler \"proxy:unix:/var/run/php/php"$PHP_FPM_VER"-fpm.sock|fcgi://localhost/\"
                        </FilesMatch>
                    </IfModule>
                </IfModule>
                BrowserMatch \"MSIE [2-6]\" \
                    nokeepalive ssl-unclean-shutdown \
                    downgrade-1.0 force-response-1.0
                # MSIE 7 and newer should be able to use keepalive
                BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown

            </VirtualHost>
        </IfModule>
        "
        echo "$blockssl" > "/etc/apache2/sites-available/$SERVER_NAME-ssl.conf"
        ln -fs "/etc/apache2/sites-available/$SERVER_NAME-ssl.conf" "/etc/apache2/sites-enabled/$SERVER_NAME-ssl.conf"
    fi

    # Enable FPM
    sudo a2enconf php"$PHP_FPM_VER"-fpm > /dev/null
    # Assume user wants mode_rewrite support
    sudo a2enmod rewrite > /dev/null
    # Turn on HTTPS support
    sudo a2enmod ssl > /dev/null
    # Turn on proxy & fcgi
    sudo a2enmod proxy proxy_fcgi > /dev/null
    # Turn on headers support
    sudo a2enmod headers actions alias > /dev/null

    # Add Mutex to config to prevent auto restart issues
    if [ -z "$(grep '^Mutex posixsem$' /etc/apache2/apache2.conf)" ]; then
        echo 'Mutex posixsem' | sudo tee -a /etc/apache2/apache2.conf
    fi

    if [ "$ADD_TO_HOSTS" == "true" ]; then
        sudo $WSLDP_GLOBAL_BIN_DIR/wsldp-hosts-add.sh "$LOCAL_IP_ADDRESS" "$SERVER_NAME"
    fi

    echo "Done. Restart Apache and all it need to handle this site"
else 
    echo "Aborted ($ROOT_DIR doesn't exist)."
    exit -1
fi
