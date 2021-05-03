#!/bin/bash

set -e

# detect if suricata is installed
if [[ $(dpkg-query -W -f='${Status}' suricata 2>/dev/null | grep -c "ok installed") -eq 1 ]]; then
    echo "Installed"
    exit 0
fi

source /opt/mistborn/scripts/subinstallers/platform.sh

# minimal dependencies
sudo -E apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential libpcap-dev   \
                libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev \
                make libmagic-dev libjansson-dev

## recommended dependencies
#sudo -E apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential libpcap-dev   \
#                libnet1-dev libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev \
#                libcap-ng-dev libcap-ng0 make libmagic-dev         \
#                libgeoip-dev liblua5.1-dev libhiredis-dev libevent-dev \
#                python-yaml rustc cargo

# iptables/nftables integration
sudo -E apt-get -y install libnetfilter-queue-dev libnetfilter-queue1  \
                libnetfilter-log-dev libnetfilter-log1      \
                libnfnetlink-dev libnfnetlink0


if [ "$DISTRO" == "ubuntu" ]; then
    echo "Installing Suricata Ubuntu PPA"
    sudo -E add-apt-repository -y ppa:oisf/suricata-stable
    sudo -E apt-get update
    sudo -E apt-get install -y suricata
elif [ "$DISTRO" == "debian" ]; then
    # retrieve version codename
    source /etc/os-release
    echo "deb http://http.debian.net/debian $VERSION_CODENAME-backports main" | \
        sudo -E tee /etc/apt/sources.list.d/suricata.list
    sudo -E apt-get update
    sudo -E apt-get install -y suricata -t ${VERSION_CODENAME}-backports
else
    echo "Basic Suricata installation"
    sudo -E apt-get install -y suricata
fi

# # iptables
# sudo iptables -A INPUT -j NFQUEUE
# sudo iptables -I FORWARD -j NFQUEUE
# sudo iptables -I OUTPUT -j NFQUEUE

# # rsyslog to create /var/log/suricata.log
# sudo cp ./scripts/conf/20-suricata.conf /etc/rsyslog.d/
# sudo chown root:root /etc/rsyslog.d/20-suricata.conf
# sudo systemctl restart rsyslog
