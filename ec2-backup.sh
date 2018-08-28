#!/bin/sh
# backup old ec2 file

DIR="/home/backup/"
test -e "$DIR" || sudo mkdir $DIR

cd $DIR || exit 1
test -e ${d}.tar.gz && rm -f ${d}.tar.gz
d=$(date +"%F")
sudo tar czvfP  ${d}.tar.gz /etc/openvpn/ /home/nginx/ /home/yorks/shadowvpn/ /home/yorks/SS/ /home/yorks/yy8.info/  --exclude="logs/*"

rsync -avP -e "ssh -lyorks -p56789" ${d}.tar.gz  jp-new.yy8.info:~/
