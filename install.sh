#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
echo "Please add the two necessary Options to your command:"
echo "./install.sh [JITSI HOSTNAME] [MAIL-ADDRESS]"
exit 0
fi

SERVERNAME=jitspriv
SERVERTYPE=ccx31
SSHPUBKEY=~/.ssh/id_rsa.pub
SSHPRIVKEY=~/.ssh/id_rsa
GITREPO=https://github.com/avpnusr/hcloud-jitsi-builder.git
SRVSTATUS=$(hcloud server list)
HCCONTEXT=$(hcloud context active)
JITSIHOSTNAME="$1"
ENCMAIL="$2"

if [ ! -r "$SSHPRIVKEY" ]; then
	echo "SSH Key does not exist"
	echo "Generating Key ..."
	ssh-keygen -t rsa -N "" -f "$SSHPRIVKEY"
fi

if [ "$HCCONTEXT" = "" ]; then
	echo "hcloud context not set, please run: hcloud context create"
fi

echosyntax ()
{
        echo "Syntax: $0"
}

hcloud server create --type "$SERVERTYPE" --name "$SERVERNAME" --image debian-10 --ssh-key $SSHPUBKEY --datacenter fsn1-dc14
IPv4=`hcloud server ip $SERVERNAME`

ssh-keygen -R "$IPv4"

SSHUP=255
while [ $SSHUP != 0 ]; do
	sleep 1
	ssh -l root -o="StrictHostKeyChecking off" $IPv4 pwd
	SSHUP=$?
done

ssh -l root -i ~/.ssh/id_rsa "$IPv4" "apt -y update && apt -y upgrade && apt -y install git && \
	cd /root && \
	git clone $GITREPO && \
	cd /root/hcloud-jitsi-builder/ && \
	/root/hcloud-jitsi-builder/run.sh ${JITSIHOSTNAME} ${ENCMAIL}"