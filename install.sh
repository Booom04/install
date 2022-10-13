#!/bin/bash
# by Booom04
#Testing only for Debian11

#彩色
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

#add source
echo 'deb http://deb.debian.org/debian buster-backports main' >>  /etc/apt/sources.list

sudo apt update -y
sudo apt install wireguard-tools wireguard-dkms -y
sleep 0.3

if [ ! -d "/etc/wireguard" ]; then
  red "wireguard install failed"
  red "Please retry and contact the author"
  exit 1
else green "wireguard install done"
fi
sleep 3

#Generate key
 wg genkey | tee privatekey | wg pubkey > publickey

#install BIRD2
wget -O - http://bird.network.cz/debian/apt.key | apt-key add -
apt-get install lsb-release -y
echo "deb http://bird.network.cz/debian/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/bird.list
apt-get update -y
apt-get install bird2 -y

#configure iptables
iptables -N DN42_INPUT
iptables -A DN42_INPUT -s 172.20.0.0/14 -j ACCEPT
iptables -A DN42_INPUT -s 172.31.0.0/16 -j ACCEPT
iptables -A DN42_INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A DN42_INPUT -s 224.0.0.0/4 -j ACCEPT
iptables -A DN42_INPUT -j REJECT
iptables -A INPUT -i dn42+ -j DN42_INPUT

iptables -N DN42_OUTPUT
iptables -A DN42_OUTPUT -d 172.20.0.0/14 -j ACCEPT
iptables -A DN42_OUTPUT -d 172.31.0.0/16 -j ACCEPT
iptables -A DN42_OUTPUT -d 10.0.0.0/8 -j ACCEPT
iptables -A DN42_OUTPUT -d 224.0.0.0/4 -j ACCEPT
iptables -A DN42_OUTPUT -j REJECT
iptables -A OUTPUT -o dn42+ -j DN42_OUTPUT

ip6tables -N DN42_INPUT
ip6tables -A DN42_INPUT -s fd00::/8 -j ACCEPT
ip6tables -A DN42_INPUT -s fe80::/10 -j ACCEPT
ip6tables -A DN42_INPUT -s ff00::/8 -j ACCEPT
ip6tables -A DN42_INPUT -j REJECT
ip6tables -A INPUT -i dn42+ -j DN42_INPUT

ip6tables -N DN42_OUTPUT
ip6tables -A DN42_OUTPUT -d fd00::/8 -j ACCEPT
ip6tables -A DN42_OUTPUT -d fe80::/10 -j ACCEPT
ip6tables -A DN42_OUTPUT -d ff00::/8 -j ACCEPT
ip6tables -A DN42_OUTPUT -j REJECT
ip6tables -A OUTPUT -o dn42+ -j DN42_OUTPUT

iptables -A FORWARD -i dn42+ -j DN42_INPUT
iptables -A FORWARD -o dn42+ -j DN42_OUTPUT

ip6tables -A FORWARD -i dn42+ -j DN42_INPUT
ip6tables -A FORWARD -o dn42+ -j DN42_OUTPUT
