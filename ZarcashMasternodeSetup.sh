#!/bin/bash

echo -e "create swap ...\n\n"
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab

echo -e "\n\nupdate & prepare system ...\n\n"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install nano htop git -y

sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common python-software-properties libzmq5-dev libminiupnpc-dev unzip -y
sudo apt-get install libboost-all-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

echo -e "\n\nsetup zarcashd ...\n\n"
cd ~
wget https://github.com/ProfProfcompile/zarcash/releases/download/v1.2.2.1/Zarcash.Unix.Linux.Cli.TX.D.V1.2.2.1.zip
sudo apt-get install unzip
chmod -R 755 /root/Zarcash.Unix.Linux.Cli.TX.D.V1.2.2.1.zip
unzip -o Zarcash.Unix.Linux.Cli.TX.D.V1.2.2.1.zip
sleep 5
mkdir /root/zarcash
mkdir /root/.zarcash
cp /root/zarcashd /root/zarcash
cp /root/zarcash-cli /root/zarcash
sleep 5
rm /root/zarcashd
rm /root/zarcash-cli
rm /root/zarcash-qt
rm /root/zarcash-tx
rm /root/Zarcash.Unix.Linux.Cli.TX.D.V1.2.2.1.zip
chmod -R 755 /root/zarcash
chmod -R 755 /root/.zarcash

echo -e "\n\nlaunch zarcashd ...\n\n"
sudo apt-get install -y pwgen
GEN_PASS=`pwgen -1 20 -n`
IP_ADD=`curl ipinfo.io/ip`

echo -e "rpcuser=zarcashuser\nrpcpassword=${GEN_PASS}\nserver=1\nlisten=1\nmaxconnections=256\ndaemon=1\nrpcallowip=127.0.0.1\nexternalip=${IP_ADD}:40444\nstaking=0" > /root/.zarcash/zarcash.conf
cd /root/zarcash
./zarcashd
sleep 40
masternodekey=$(./zarcash-cli masternode genkey)
./zarcash-cli stop

# add launch after reboot
crontab -l > tempcron
echo "@reboot /root/zarcash/zarcashd -reindex >/dev/null 2>&1" >> tempcron
crontab tempcron
rm tempcron

echo -e "masternode=1\nmasternodeprivkey=$masternodekey\n\n\n" >> /root/.zarcash/zarcash.conf


./zarcashd -daemon
cd /root/.zarcash
ufw allow 40444

# output masternode key
echo -e "Masternode private key: $masternodekey"
echo -e "Welcome to the Zarcash Masternode Network!"

