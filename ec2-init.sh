#!/bin/sh

for i in `chkconfig --list | grep 3:on | egrep -v "network|sshd" | awk '{print $1}' `; do echo $i; chkconfig $i off;done
/etc/init.d/sendmail stop

yum -y -q install automake libtool git
chkconfig --list | grep 3:on

# user
useradd yorks
cp /etc/skel/.bash* /home/yorks/
sed -i 's/ec2-user/yorks/g' /etc/sudoers.d/cloud-init
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
UsePrivilegeSeparation sandbox          # Default for new installations.
UseDNS no
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem       sftp    /usr/libexec/openssh/sftp-server
AllowUsers yorks
_EOF
cat /tmp/sshd_config  > /etc/ssh/sshd_config
/bin/rm -f /tmp/sshd_config
mkdir -p /home/yorks/.ssh
cat /home/ec2-user/.ssh/authorized_keys  > /home/yorks/.ssh/authorized_keys
chmod 600 /home/yorks/.ssh/authorized_keys
chown yorks.yorks /home/yorks/.ssh/authorized_keys
chown -R yorks.yorks /home/yorks/
/usr/sbin/sshd -t && /etc/init.d/sshd reload
# cron
/etc/init.d/crond status
sed -i 's/MAILTO=root/MAILTO=""/g' /etc/crontab
sed -i 's/MAILTO=root/MAILTO=""/g' /etc/cron.d/0hourly
grep MAIL /etc/cron*
grep MAIL /etc/cron*/*
