#!/bin/bash

source ./ENVSETTINGS
APTINSTALL=""

cd ~

$JITSILINK="https://github.com/$(curl -sL "https://github.com/jitsi/docker-jitsi-meet/releases/latest" | grep .tar.gz | awk -F 'href="' '{print $2}' | awk -F '" rel=' '{print $1}')"

echo "Docker ..."
if [ ! -x /usr/bin/docker ]; then
	echo -e "   ${RED}not found${NC} - starting installation!"
	curl -fsSL https://get.docker.com | bash -
else
	echo -e "  ${GREEN}OK${NC} - already installed."
fi

echo "Docker Compose..."
if [ ! -x /usr/local/bin/docker-compose ]; then
	echo -e "   ${RED}not found${NC} - starting installation!"
	wget -O /usr/local/bin/docker-compose "https://github.com/$(curl -L "https://github.com/docker/compose/releases/latest" | grep -E -m1 "$(uname -s).*$(uname -m)" | awk -F 'href="' '{print $2}' | awk -F '" rel=' '{print $1}')"
	chmod +x /usr/local/bin/docker-compose
else
	echo -e "  ${GREEN}OK${NC} - already installed."
fi


cd ~
wget -O jitsi-docker.tar.gz "https://github.com/$(curl -sL "https://github.com/jitsi/docker-jitsi-meet/releases/latest" | grep .tar.gz | awk -F 'href="' '{print $2}' | awk -F '" rel=' '{print $1}')"
mkdir jitsi-docker && tar -xf jitsi-docker.tar.gz --strip-components 1 -C ./jitsi-docker && cd jitsi-docker
cp env.example .env
./gen-passwords.sh
sed -i "s/#PUBLIC_URL.*$/PUBLIC_URL=${JITSIHOSTNAME}/" .env
sed -i "s/#ENABLE_LETSENCRYPT=1/ENABLE_LETSENCRYPT=1/" .env
sed -i "s/#LETSENCRYPT_DOMAIN=meet.example.com/LETSENCRYPT_DOMAIN=${JITSIHOSTNAME}/" .env
sed -i "s/#LETSENCRYPT_EMAIL=alice@atlanta.net/LETSENCRYPT_EMAIL=${ENCMAIL}/" .env
sed -i "s/HTTP_PORT=8000/HTTP_PORT=80/" .env
sed -i "s/HTTPS_PORT=8443/HTTPS_PORT=443/" .env
sed -i "s/TZ=UTC/TZ=Europe\/Berlin/" .env

mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
docker-compose up -d