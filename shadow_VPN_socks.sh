#!/bin/sh

password=$1
vpassword=$(echo $password | md5sum | awk '{print $1}')
wget -c -O ShadowVPN-0.2.1.tar.gz https://github.com/rains31/ShadowVPN/archive/0.2.1.tar.gz
tar zxvf ShadowVPN-0.2.1.tar.gz
cd ShadowVPN-0.2.1
git clone https://github.com/jedisct1/libsodium.git
sh autogen.sh
./configure --enable-static --sysconfdir=/home/yorks/shadownvpn/etc  --prefix=/home/yorks/shadownvpn
make && make install
sed -i "s/=my_password/=$vpassword/g" /home/yorks/shadownvpn/etc/shadowvpn/server.conf
mkdir -p /home/yorks/shadownvpn/var/run
mkdir -p /home/yorks/shadownvpn/var/log
sed -i 's#=/var/#=/home/yorks/shadownvpn/var/#g' /home/yorks/shadownvpn/etc/shadowvpn/server.conf 
sed -i 's#=/etc/#=/home/yorks/shadownvpn/etc/#g' /home/yorks/shadownvpn/etc/shadowvpn/server.conf

sudo /home/yorks/shadownvpn/bin/shadowvpn -c /home/yorks/shadownvpn/etc/shadowvpn/server.conf -s start
sudo yum -q -y install swig openssl-devel.x86_64
sudo pip install shadowsocks
sudo pip install m2crypto

cd ~
cat > ss.json <<_EOF
{
    "server":"0.0.0.0",
    "server_port":8888,
    "local_port":1080,
    "password":"$password",
    "timeout":300,
    "method":"aes-256-cfb",
    "local_address":"127.0.0.1",
    "fast_open":false
}
_EOF
sudo /usr/local/bin/ssserver -c ss.json --log-file ./ss.log --pid-file ./ss.pid -d start

echo "pls add ports: 8888(tcp) 1123(udp) to aws sec rules."
