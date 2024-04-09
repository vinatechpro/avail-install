#!/bin/bash
echo "Kill Avail Light Client Service..."

pkill -9 avail-light

echo "------------------ Remove Avail Path & Old Config ------------------------"
rm -rf /root/avail-light/config.yml
rm -rf /root/avail_path

echo "------------------ Create New Config ------------------------"
curl -o https://raw.githubusercontent.com/vinatechpro/avail-install/main/config.yml && cp -r config.yml /root/avail-light
echo ""

echo "------------------ Remove File Avail Systemd ------------------------"
rm -rf /etc/systemd/system/avail-light.service

echo "------------------ Create New File Avail Light Systemd ------------------------"

touch /etc/systemd/system/avail-light.service
echo "[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
WorkingDirectory=/root
ExecStart= /root/avail-light/target/release/avail-light --config /root/avail-light/config.yml --identity /root/avail-light/target/release/identity.toml
Restart=always
RestartSec=120
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/avail-light.service

echo "------------------ Restart Avail Service ------------------------"
systemctl daemon-reload
systemctl enable avail-light.service && systemctl start avail-light.service

sleep 5

systemctl status avail-light.service
