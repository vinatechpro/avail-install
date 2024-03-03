#!/bin/bash
echo "

'##::::'##:'####:'##::: ##::::'###::::'########:'########::'######::'##::::'##:
 ##:::: ##:. ##:: ###:: ##:::'## ##:::... ##..:: ##.....::'##... ##: ##:::: ##:
 ##:::: ##:: ##:: ####: ##::'##:. ##::::: ##:::: ##::::::: ##:::..:: ##:::: ##:
 ##:::: ##:: ##:: ## ## ##:'##:::. ##:::: ##:::: ######::: ##::::::: #########:
. ##:: ##::: ##:: ##. ####: #########:::: ##:::: ##...:::: ##::::::: ##.... ##:
:. ## ##:::: ##:: ##:. ###: ##.... ##:::: ##:::: ##::::::: ##::: ##: ##:::: ##:
::. ###::::'####: ##::. ##: ##:::: ##:::: ##:::: ########:. ######:: ##:::: ##:
:::...:::::....::..::::..::..:::::..:::::..:::::........:::......:::..:::::..::
                                                                                                                                                  
"
echo "------------------------------------------------------------------------"
echo ""
echo "AVAIL LIGHT CLIENT INSTALL"                                         
echo -n "Import your seed phrase (12 word): "
read seed
echo ""
echo "------------------------------------------------------------------------"
echo ""
echo "------------------ Start Install Package & Dependency ------------------"
yes | sudo apt-get update & sudo apt-get upgrade -y && yes | sudo apt install nano make build-essential git clang curl ufw libssl-dev protobuf-compiler --assume-yes
echo ""

echo "---------------------------- Open Port --------------------------------"
sudo ufw allow 22 && sudo ufw allow 80 && sudo ufw allow 443 && sudo ufw allow 30333 && sudo ufw allow 9933 && sudo ufw allow 9615 && sudo ufw allow 9944 && sudo ufw allow 7000 && sudo ufw allow 37000 && yes | sudo ufw enable && sudo ufw status
echo ""

echo "----------------- Download & Install Light Client ---------------------"
cd ~ && git clone https://github.com/availproject/avail-light.git && cd avail-light && git checkout v1.7.9-rc1 && cargo build --release
echo ""

echo "------------------ Create File Avail Light Systemd ------------------------"
touch /etc/systemd/system/avail-light.service
echo "[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
ExecStart= /root/avail-light/target/release/avail-light --identity '/root/avail-light/target/release/identity.toml' --network goldberg
Restart=always
RestartSec=120
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/avail-light.service

echo ""

echo "Your seed file here: ~/avail-light/target/release/identity.toml"
touch ~/avail-light/target/release/identity.toml
echo "avail_secret_seed_phrase = '$seed'" > ~/avail-light/target/release/identity.toml

echo ""

sudo systemctl daemon-reload && systemctl enable avail-light.service && systemctl start avail-light.service
sleep 3
systemctl status avail-light.service