#!/bin/sh

#
# disable autostart svr
#
systemctl list-unit-files  | 
    awk '$1 ~ /service$/ && $2 ~ /enabled/{ print $1}' > /root/.init.autostart.list
for svr in `cat /root/.init.autostart.list`; do 
    [[ "x$svr" == "xsshd.service" ]] && continue
    [[ "x$svr" == "xnetwork.service" ]] && continue
    [[ "x$svr" == "xirqbalance.service" ]] && continue
    systemctl disable $svr
done
systemctl stop rpcbind.socket
systemctl disable  rpcbind.socket


yum -y -q install automake libtool git

#
# user
#
useradd yorks 2>>/dev/null
cp /etc/skel/.bash* /home/yorks/
grep -q HISTSIZE /etc/profile || echo 'export HISTSIZE="999999"' >> /etc/profile
grep -q HISTTIMEFORMAT /etc/profile || echo 'export HISTTIMEFORMAT="[%F %T] "' >> /etc/profile
grep -q HISTFILESIZE   /etc/profile || echo 'export HISTFILESIZE="999999"' >> /etc/profile

grep -q ^alias /home/yorks/.bashrc || echo "alias ls='ls --color'" >> /home/yorks/.bashrc


mkdir -p /home/yorks/.ssh
cat /home/ec2-user/.ssh/authorized_keys  > /home/yorks/.ssh/authorized_keys
chmod 600 /home/yorks/.ssh/authorized_keys
chown yorks.yorks /home/yorks/.ssh/authorized_keys
chown -R yorks.yorks /home/yorks/
sed -i 's/ec2-user/yorks/g' /etc/sudoers.d/*
# sshd
cat > /tmp/sshd_config <<_EOF
Port 56789
Port 9922
SyslogFacility AUTHPRIV
PermitRootLogin no
AuthorizedKeysFile      .ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
AllowTcpForwarding yes
X11Forwarding yes
PrintMotd no
PrintLastLog yes
UseDNS no
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
AllowUsers yorks
_EOF
grep "^Subsystem" /etc/ssh/sshd_config >> /tmp/sshd_config
cat /tmp/sshd_config  > /etc/ssh/sshd_config
/bin/rm -f /tmp/sshd_config

/usr/sbin/sshd -t &&  systemctl  reload sshd
echo -e "\033[40;31;1;5m pls check login before logout!! \033[0m"


#
# openvpn
#
yum -q install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum clean all >/dev/null 2>&1
yum -q install openvpn.x86_64
test -e /usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so || {
      mkdir -p /usr/lib64/openvpn/plugin/lib/
  ln -s ../../plugins/openvpn-plugin-auth-pam.so /usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so
}


#
# cron
#
sed -i 's/MAILTO=root/MAILTO=""/g' /etc/crontab
sed -i 's/MAILTO=root/MAILTO=""/g' /etc/cron.d/0hourly
grep MAIL /etc/cron* 2>/dev/null
grep MAIL /etc/cron*/* 2>/dev/null


#
# my autostart svr
#
grep -q ssserver.sh /etc/rc.d/rc.local || echo 'su - yorks -c "sh /home/yorks/SS/bin/ssserver.sh"' >> /etc/rc.d/rc.local
grep -q nginx /etc/rc.d/rc.local || echo '/home/nginx/sbin/nginx' >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
