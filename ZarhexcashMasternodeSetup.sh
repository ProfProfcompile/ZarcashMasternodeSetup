#!/bin/bash

echo -e "Welcome to all in one Zarhexcash Masternode Install    ...\n\n"
sleep 15
echo -sleep 5e "Stopping any instance of Zarhexcash Masternodes   ...\n\n"
sleep 5
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

sudo apt-get install nano htop git -y

sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common python-software-properties libzmq5-dev libminiupnpc-dev unzip -y
sudo apt-get install libboost-all-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

echo -e "\n\nsetup zarhexcashd ...\n\n"
cd ~
wget https://github.com/ProfProfcompile/zarhexcash/releases/download/v1.2.3.6/ZarhexcashLinuxV1.2.3.6ALL.zip
sudo apt-get install unzip
chmod -R 755 ZarhexcashLinuxV1.2.3.6ALL.zip
unzip -o ZarhexcashLinuxV1.2.3.6ALL.zip
sleep 5
mkdir /root/zarhexcash
mkdir /root/.zarhexcash
cp /root/zarhexcashd /root/zarhexcash
cp /root/zarhexcash-cli /root/zarhexcash
sleep 5
rm /root/zarhexcashd
rm /root/zarhexcash-cli
rm /root/zarhexcash-qt
rm /root/zarhexcash-tx
rm /root/ZarhexcashLinuxV1.2.3.6ALL.zip
chmod -R 755 /root/zarhexcash
chmod -R 755 /root/.zarhexcash

echo -e "\n\nlaunch zarhexcashd ...\n\n"
sudo apt-get install -y pwgen
GEN_PASS=`pwgen -1 20 -n`
IP_ADD=`curl ipinfo.io/ip`

echo -e "rpcuser=zarhexcashuser\nrpcpassword=${GEN_PASS}\nserver=1\nlisten=1\nmaxconnections=256\ndaemon=1\nrpcallowip=127.0.0.1\nexternalip=${IP_ADD}:40444\nstaking=0" > /root/.zarhexcash/zarhexcash.conf
cd /root/zarhexcash
./zarhexcashd
sleep 40
masternodekey=$(./zarhexcash-cli masternode genkey)
./zarhexcash-cli stop

# add launch after reboot
crontab -l > tempcron
echo "@reboot /root/zarhexcash/zarhexcashd -reindex >/dev/null 2>&1" >> tempcron
crontab tempcron
rm tempcron

echo -e "masternode=1\nmasternodeprivkey=$masternodekey\n\n\n" >> /root/.zarhexcash/zarhexcash.conf


./zarhexcashd -daemon
cd /root/.zarhexcash
ufw allow 40445

# output masternode key
echo -e "Masternode private key: $masternodekey"
echo -e "Welcome to the Zarhexcash Masternode Network!"

