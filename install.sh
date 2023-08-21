#!/bin/bash

# Update package lists
sudo apt-get update -y

# Upgrade installed packages
sudo apt-get upgrade -y

# Clean up package cache
sudo apt-get autoclean -y

# Remove unused packages
sudo apt-get autoremove -y

# Install 'screen' and 'unzip'
sudo apt-get install -y screen unzip

# Download badvpn-udpgw
sudo wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64"
sudo chmod +x /usr/bin/badvpn-udpgw

# Create rc-local.service file
sudo tee /etc/systemd/system/rc-local.service > /dev/null << EOL
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOL

# Make /etc/rc.local executable
sudo chmod +x /etc/rc.local
printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local

# Enable and start rc-local.service
sudo systemctl enable rc-local
sudo systemctl start rc-local.service

# Add content to /etc/rc.local
sudo tee /etc/rc.local > /dev/null << EOL
#!/bin/sh -e
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
exit 0
EOL
sudo chmod +x /etc/rc.local

# Display listening ports
lsof -i -P -n | grep LISTEN

# Reboot the system
sudo reboot