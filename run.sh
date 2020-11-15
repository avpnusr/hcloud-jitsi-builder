#!/bin/bash

source ./ENVSETTINGS
APTINSTALL=""

echo "Docker ..."
if [ ! -x /usr/bin/docker ]; then
	echo -e "   ${RED}not found${NC} - starting installation!"
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh > /dev/null
else
	echo -e "  ${GREEN}OK${NC} - already installed."
fi



	
