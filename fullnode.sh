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
echo "AVAIL FULLNODE INSTALL"                                         
echo -n "Type Your Fullnode Name: "
read node_name
echo ""
echo "------------------------------------------------------------------------"
echo ""
echo "------------------ Start Install Package & Dependency ------------------"
yes | sudo apt-get update & sudo apt-get upgrade -y && sudo apt install nano make build-essential git clang curl libssl-dev protobuf-compiler --assume-yes
echo ""

echo "---------------------------- Open Port --------------------------------"
sudo apt-get install ufw -y && sudo ufw allow 22 && sudo ufw allow 80 && sudo ufw allow 443 && sudo ufw allow 30333 && sudo ufw allow 9933 && sudo ufw allow 9615 && sudo ufw allow 9944 && sudo ufw allow 7000 && sudo ufw allow 37000 && yes | sudo ufw enable && sudo ufw status
echo ""

echo "--------------------- Install & Config Rust --------------------------"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source ~/.cargo/env && rustup default stable && rustup update && rustup update nightly && rustup target add wasm32-unknown-unknown --toolchain nightly
echo ""

echo "------- Download Avail Fullnode Source via Github & Install ---------"
cd ~ && sudo rm -rf avail && git clone https://github.com/availproject/avail.git && cd avail && mkdir -p output && git checkout v1.11.0.0 && cargo build --locked --release && echo ""

echo "--------------------- Download snapshot DB --------------------------"
sudo rm -rf ~/avail/output/chains/avail_goldberg_testnet/db/* && sudo rm -rf ~/avail/output/chains/avail_goldberg_testnet/network/* && sudo apt-get -y install lz4
echo "Download..."
curl -o - -L http://snapshots.staking4all.org/snapshots/avail/latest/avail.tar.lz4 | lz4 -c -d - | tar -x -C ~/avail/output/chains/avail_goldberg_testnet/
echo ""

echo "------------------ Create File Avail Systemd ------------------------"
sudo touch /etc/systemd/system/availd.service
echo "[Unit] 
Description=Avail Fullnode
After=network.target
StartLimitIntervalSec=0
[Service] 
User=root 
ExecStart= /root/avail/target/release/data-avail -d /root/avail/output --chain goldberg --name '$node_name'
Restart=always 
RestartSec=120
[Install] 
WantedBy=multi-user.target" > /etc/systemd/system/availd.service

echo ""

sudo systemctl daemon-reload && systemctl enable availd.service && systemctl start availd.service && systemctl status availd.service

echo "DONE."
