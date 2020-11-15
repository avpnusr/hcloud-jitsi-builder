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

cd /root
git clone https://github.com/jitsi/docker-jitsi-meet && cd docker-jitsi-meet
cp env.example .en
./gen-passwords.sh
mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
docker-compose up -d


	
