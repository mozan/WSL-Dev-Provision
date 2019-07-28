#!/bin/bash

#
# Neo4j
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_NEO4J" == "y" ]; then
	echoBanner "DB - neo4j"
	checkIfInstalled "db-neo4j" "DB - neo4j"
	if [ "$?" == "0" ]; then
		apt-get $APT_SILENCE install -y neo4j
		service neo4j stop

		# Configure Neo4j Remote Access
		sed -i "s/#dbms.connectors.default_listen_address=0.0.0.0/dbms.connectors.default_listen_address=0.0.0.0/" /etc/neo4j/neo4j.conf

		# Enable Neo4j as a system service
		service neo4j start

		# Poll for Neo4j
		end="$((SECONDS+60))"
		while true; do
			nc -w 2 localhost 7687 && break
			[[ "${SECONDS}" -ge "${end}" ]] && exit 1
			sleep 1
		done

		# Add new user
		cypher-shell -u neo4j -p neo4j "CALL dbms.changePassword('$DB_PASSWORD');"
		cypher-shell -u neo4j -p $DB_PASSWORD "CALL dbms.security.createUser('$DB_ADMIN_USERNAME', '$DB_PASSWORD', false);"

		# Delete default user
		cypher-shell -u $DB_ADMIN_USERNAME -p $DB_PASSWORD "CALL dbms.security.deleteUser('neo4j');"

		service neo4j stop

		addToMemoire "Neo4j - WARNING: Max 1024 open files allowed, minimum of 40000 recommended. See the Neo4j manual."
		addToMemoire "      - Please use Oracle(R) Java(TM) 8, OpenJDK(TM) or IBM J9 to run Neo4j."
		addToMemoire "      - Please see https://neo4j.com/docs/ for Neo4j installation instructions."

		autorunService "neo4j"
		setAsInstalled "db-neo4j"
	fi
fi
