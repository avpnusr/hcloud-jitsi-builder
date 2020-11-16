#!/bin/bash

source ./ENVSETTINGS
APTINSTALL=""
cd ~

echo "Docker ..."
if [ ! -x /usr/bin/docker ]; then
	echo -e "   ${RED}not found${NC} - starting installation!"
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh > /dev/null
else
	echo -e "  ${GREEN}OK${NC} - already installed."
fi

echo "Docker Compose..."
if [ ! -x /usr/local/bin/docker-compose ]; then
	echo -e "   ${RED}not found${NC} - starting installation!"
	sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
else
	echo -e "  ${GREEN}OK${NC} - already installed."
fi


cd ~
git clone https://github.com/jitsi/docker-jitsi-meet && cd docker-jitsi-meet
cp env.example .env
./gen-passwords.sh
mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
# docker-compose up -d


	
