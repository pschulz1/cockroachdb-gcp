#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log) 2>&1

# Set local/private IP address
local_ipv4="$(echo -e `hostname -I` | tr -d '[:space:]')"
local_hostname="$('hostname')"
CRDB_REGION=${region}
CRDB_ZONE=${zone}

#######################
# Prepare non-boot disk
#######################

logger "Mounting and formatting 2nd drive"

MNT_DIR=/mnt/disks/persistent_storage

if [[ -d "$MNT_DIR" ]]; then
        exit
else 
        sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb; \
        sudo mkdir -p $MNT_DIR
        sudo mount -o discard,defaults /dev/sdb $MNT_DIR

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value /dev/sdb` $MNT_DIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
fi

#######################
# Install Prerequisites
#######################

logger "Installing jq"

sudo curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq1

logger  "Setting timezone to Europe/Berlin"
sudo timedatectl set-timezone Europe/Berlin

logger "Performing updates and installing prerequisites"
sudo apt-get -qq -y update
sudo apt-get install -qq -y wget unzip dnsutils ntp
sudo systemctl start ntp.service
sudo systemctl enable ntp.service

logger "Completed Installing Prerequisites"

##################
# Set up CRDB user
##################

logger "Adding CockroachDB user"

sudo useradd --system --home /etc/cockroach.d --shell /bin/false cockroach


############################
# Install and configure crdb
############################

logger "Downloading CockroachDB"

mkdir /tmp
wget -P /tmp https://binaries.cockroachdb.com/cockroach-${crdb_version}.linux-amd64.tgz

logger "Installing CockroachDB"

sudo tar -xzf /tmp/cockroach-${crdb_version}.linux-amd64.tgz -C /tmp/
sudo cp -i /tmp/cockroach-${crdb_version}.linux-amd64/cockroach /usr/local/bin/

sudo chmod 0755 /usr/local/bin/cockroach
sudo chown cockroach:cockroach /usr/local/bin/cockroach

sudo mkdir -p /usr/local/lib/cockroach
sudo cp -i /tmp/cockroach-${crdb_version}.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
sudo cp -i /tmp/cockroach-${crdb_version}.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/
sudo chown cockroach:cockroach /usr/local/lib/cockroach/libgeos.so
sudo chown cockroach:cockroach /usr/local/lib/cockroach/libgeos_c.so 

sudo mkdir -pm 0755 /etc/cockroach.d
sudo mkdir -pm 0755 /mnt/disks/persistent_storage/cockroach/data
sudo chown cockroach:cockroach /mnt/disks/persistent_storage/cockroach/data


##################################
# Create cockroach systemd service
##################################

logger "Registering CockroachDB daemon"

sudo sudo touch /etc/systemd/system/cockroach.service
sudo chmod 0664 /etc/systemd/system/cockroach.service
sudo tee /etc/systemd/system/cockroach.service <<EOF
[Unit]
Description=cockroach
Requires=network-online.target
After=network-online.target
[Service]
Restart=on-failure
ExecStart=/usr/local/bin/cockroach start --join=crdb-node-1:26257,crdb-node-2:26257,crdb-node-3:26257 --store=/mnt/disks/persistent_storage/cockroach/data  --locality=region=${region},zone=${zone} --insecure
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=60
User=cockroach
Group=cockroach
[Install]
WantedBy=multi-user.target
EOF

logger "Starting CockroachDB daemon"

sudo systemctl enable cockroach
sudo systemctl start cockroach
sudo systemctl status cockroach

logger "Completed Configuration of Cockroach Node, not initialized yet!"