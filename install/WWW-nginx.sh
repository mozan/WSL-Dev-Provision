#!/bin/bash

#
# NGINX
if [ "$INSTALL_WWW_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_NGINX" == "y" ]; then
	echoBanner "WWW - nginx"
	checkIfInstalled "www-nginx" "WWW - nginx"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages nginx

		# TODO
		# Copy fastcgi_params to Nginx because they broke it on the PPA
		cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param	QUERY_STRING		\$query_string;
fastcgi_param	REQUEST_METHOD		\$request_method;
fastcgi_param	CONTENT_TYPE		\$content_type;
fastcgi_param	CONTENT_LENGTH		\$content_length;
fastcgi_param	SCRIPT_FILENAME		\$request_filename;
fastcgi_param	SCRIPT_NAME		\$fastcgi_script_name;
fastcgi_param	REQUEST_URI		\$request_uri;
fastcgi_param	DOCUMENT_URI		\$document_uri;
fastcgi_param	DOCUMENT_ROOT		\$document_root;
fastcgi_param	SERVER_PROTOCOL		\$server_protocol;
fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;
fastcgi_param	REMOTE_ADDR		\$remote_addr;
fastcgi_param	REMOTE_PORT		\$remote_port;
fastcgi_param	SERVER_ADDR		\$server_addr;
fastcgi_param	SERVER_PORT		\$server_port;
fastcgi_param	SERVER_NAME		\$server_name;
fastcgi_param	HTTPS			\$https if_not_empty;
fastcgi_param	REDIRECT_STATUS		200;
EOF

		# Set the Nginx user
		sed -i "s/user www-data;/user $INSTALLED_FOR_USER;/" /etc/nginx/nginx.conf
		sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

		# copy scripts to WSLDP_GLOBAL_BIN_DIR
		cp ./resources/bin/wsldp-create-site-nginx.sh $WSLDP_GLOBAL_BIN_DIR/ 2> /dev/null
# TODO cleanup
		setEnvWSLDPScriptsGlobals WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_CONFIG_DIR $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-nginx.sh
		sed -i "s#/etc/nginx/ssl#$WSLDP_GLOBAL_CONFIG_DIR/certificates#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-nginx.sh
		sed -i "s#LOCAL_IP_ADDRESS=127.0.0.1#LOCAL_IP_ADDRESS=$LOCAL_IP_ADDRESS#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-nginx.sh
		sed -i "s#WSLDP_GLOBAL_BIN_DIR=/usr/local/bin#WSLDP_GLOBAL_BIN_DIR=$WSLDP_GLOBAL_BIN_DIR#" $WSLDP_GLOBAL_BIN_DIR/wsldp-create-site-nginx.sh

		# install aliases
		installAliases ./resources/shell/bash_aliases_nginx

		autorunService "nginx"
		setAsInstalled "www-nginx"
	fi
fi
