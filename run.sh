#!/bin/bash

IPT=/sbin/iptables
JITSIHOSTNAME="$1"
ENCMAIL="$2"

cd ~

echo "Docker installation, if needed."
if [ ! -x /usr/bin/docker ]; then
	echo "docker not found - starting installation!"
	curl -fsSL https://get.docker.com | bash -
else
	echo "docker already installed."
fi

echo "Checking for docker-compose, installing if needed."
if [ ! -x /usr/local/bin/docker-compose ]; then
	echo "docker-compose not found - starting installation!"
	wget -q -O /usr/local/bin/docker-compose "https://github.com/$(curl -sL "https://github.com/docker/compose/releases/latest" | grep -E -m1 "$(uname -s).*$(uname -m)" | awk -F 'href="' '{print $2}' | awk -F '" rel=' '{print $1}')"
	chmod +x /usr/local/bin/docker-compose
else
	echo "docker-compose already installed."
fi


cd ~
wget -q -O jitsi-docker.tar.gz "https://github.com/$(curl -sL "https://github.com/jitsi/docker-jitsi-meet/releases/latest" | grep .tar.gz | awk -F 'href="' '{print $2}' | awk -F '" rel=' '{print $1}')"
mkdir jitsi-docker && tar -xf jitsi-docker.tar.gz --strip-components 1 -C ./jitsi-docker && rm jitsi-docker.tar.gz && cd jitsi-docker
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

## Cleaning fw-rules
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F
$IPT -X

## Restarting Docker to recreate fw-chains
service docker restart

## Setting up fw-rules
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
$IPT -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
$IPT -A INPUT -i eth0 -p tcp --dport 443 -j ACCEPT
$IPT -A INPUT -i eth0 -p udp --dport 10000 -j ACCEPT
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -i eth0 -j DROP

## Starting jitsi containers
docker-compose up -d