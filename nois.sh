#!/bin/bash

echo -e "\033[1;36m"
echo " ::::::'##:'########:'########:'########::'####:'##::::'## ";
echo " :::::: ##: ##.....::... ##..:: ##.... ##:. ##::. ##::'## ";
echo " :::::: ##: ##:::::::::: ##:::: ##:::: ##:: ##:::. ##'## ";
echo " :::::: ##: ######:::::: ##:::: ########::: ##::::. ### ";
echo " '##::: ##: ##...::::::: ##:::: ##.. ##:::: ##:::: ## ## ";
echo "  ##::: ##: ##:::::::::: ##:::: ##::. ##::: ##::: ##:. ## ";
echo " . ######:: ########:::: ##:::: ##:::. ##:'####: ##:::. ## ";
echo " :......:::........:::::..:::::..:::::..::....::..:::::..::";
echo -e "\e[0m"


sleep 2

# set vars
if [ ! $NOIS_NODENAME ]; then
	read -p "Enter node name: " NOIS_NODENAME
	echo 'export NOIS_NODENAME='$NOIS_NODENAME >> $HOME/.bash_profile
fi
if [ ! $NOIS_PORT ]; then
	read -p "Enter node port: " NOIS_PORT
	echo 'export NOIS_PORT='$NOIS_PORT >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NOIS_CHAIN_ID=nois-testnet-002" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NOIS_NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$NOIS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$NOIS_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/noislabs/full-node.git 
cd full-node/full-node/
./setup.sh
cd $HOME
mv full-node/full-node/out/noisd /usr/local/go/bin/


# config
noisd config chain-id $NOIS_CHAIN_ID
noisd config keyring-backend test
noisd config node tcp://localhost:${NOIS_PORT}657

# init
noisd init $NOIS_NODENAME --chain-id $NOIS_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.noisd/config/genesis.json "https://raw.githubusercontent.com/noislabs/testnets/main/nois-testnet-002/genesis.json"

# set peers and seeds
SEEDS=""
PEERS=19ebc9767308ff076bf470070d04746290b3e24b@198.244.179.62:26656,0b77ae4e52c21d01ace4e2371a636bd7e35cea69@135.181.176.109:59656,6f37739579a37e0a1ffe071301d72abe41b17451@158.101.209.61:26656,7444d776b4a092d6631249d456cac4090627e2ae@65.108.194.40:26456,6aa8954ec883ae1363f6107fe18953a2eda2c510@176.100.3.29:26356,0983608d136058602a623d0198b3e7e1fbf2c989@38.242.198.130:36656,4f0db2c5875df57df6421b87ae99f74574d2e9a7@78.107.234.44:35656,b7f94fe0324d46be8407fe67dcf80dc67e4627a8@194.163.185.188:26656,6185adfb45beb77d9087dd32ada17c293c68be6e@135.181.116.109:26656,380d8e530bc16ce2df2c435b9529ad20d5495f22@161.97.151.40:33656,35a86b452c794ed112840378aff5ca4a6a69fe0a@154.12.228.189:26656,58d74964df43371bc33a7ba4132de43a0bb071dc@65.109.53.53:60656,e7a2c43547de2010e66e473c865d0666067d6ecb@38.242.128.88:12656,48d87a6669ffee319f364795fb220ed086a01f55@35.153.71.164:26656,5186ba662239932e8ef729cfe486b19a8f839c28@95.217.207.236:23356,6d584f7501018441efa3815ad4d50619075708f0@65.108.195.235:13656,443797491a0943838527f2c846f382621e410738@65.108.43.227:26656,99ad25781c62b495d2e6166215452a45e1701e47@195.201.165.123:21036,44b7acd072e4ed3db0d41237befb602f1fecb2f0@49.12.236.218:26656,8bd96456e1593e7b062b6001609f327a853fb5b4@65.108.81.83:26656,8538d1adef3ecb541c73167384cf722f921163a4@162.55.235.69:33656,da2945fede11a6726b6d92d21c6e7138bcffd15f@67.205.142.207:10656,2211b72151868c7299142a452257f7dc2886de2e@142.132.182.1:14656,da5561c6cc72b666cc8e15386790ada9cb664b7b@149.102.136.184:12656,a87dc8b4e827a05fe5c46aea54999120c8252587@54.37.6.16:26656,ab92009e773d3d7e8b464b73340164540b506f11@159.223.54.69:26656,8073bd66d5fa581c7b3d0a08d0df1fe318d70d99@135.181.35.46:55656,09abc7a43c626c668367633c0dd5f25da7a8deef@65.109.55.186:10656,cc1a9320eaf1899dd0ffe4b226d729ab00c4b57d@178.211.139.124:10656,c26a53b97a974e5c8dd81d131c3aacb4da0d8f99@173.249.22.168:10656,585575ebeadd8ab8cca992e2c387303673a288d4@135.181.248.69:36656,4214e71d0887f0b9fdac356eefc035e66afd4456@65.108.193.133:12656,5ccd553827dcabc4c48d23228a9875c2f5366028@65.108.241.219:10656,ed1663ad104366cc7de9460a74ff799d5d55f6dd@65.108.103.86:10656,e2b12f0013a032a66c1b18ea0143937ac62c98fc@62.171.142.94:26656,e59e316ea8be3b0582bb79346eb74624c4e4ddb6@161.97.160.86:55656,3dadb0d6975d1b1b456a59403be0f4d6ca9e4ab2@164.92.156.241:10656,d1b820dab0c4542f1e2a599f08800c725cd991ef@38.242.133.200:10656,2081a2900bf2e4f48b80c67a9b98e0e5373c540a@95.216.193.249:10656,04180c824f30c10a5a2e5430b7e6158fd46ed3fa@167.235.137.16:10656,730522c5db98a432d259d8efb495862b82ffdcbe@178.18.244.98:55656,358710e0bed20e427b6702275c59e43b9aaca9da@65.21.55.105:10656,93ced80f0426c373802a6e6538b501f5af3bbf78@2.58.82.107:10656,32db5114df24e693cc1520f1adde9a0c12a1854c@35.232.228.166:10656,7ea2ddf751659d184f544233808e4f508d80e3f2@176.58.125.214:10656,38580721b2325e281e9cb082522e6cba9ab5553f@213.136.88.28:10656,edc9fd69a299d95ffb0777618ab64c6e9cb39e67@62.171.156.113:10656,3d016efb24c4522155baf90645edbe58ff9fbb75@199.247.6.215:10656,3e3021114400105bed4c040e93d37aeffe71aa6f@34.170.203.212:10656,54f6d359cccdf5e51e25942a0f62069f64365d13@157.230.178.228:10656,1d5b6d33cde619d0073716f65492a4af3735d745@157.90.24.215:10656,3b545c5c67b5997b235d25a02858ae1bcb5d6e37@149.102.159.127:10656,cd9dac4178ac398f2ea47ed8f3555701c5f44af1@159.203.12.167:10656,1d473fd82e326d2e19592baa703e2134f2c159fe@157.245.251.189:10656,11b3f2dd224af006aca3f9b6525d1b952e12987a@185.169.252.86:10656,7bc94e6463eacadb6670c9f8f971b99eb75ec381@38.242.212.47:10656,10388dc66ea4e57bc70cda45f2dcc17ea7b19c5f@95.216.190.86:10656,e85038846f7fbf52c904ef7a7ce1fcd801e45278@38.242.141.12:10656,282e1803bf04497b3d4839fdd5047b43971165d9@185.205.244.21:30656,ac05c0fcaf0fdeea870df43853cb48fbc1bc3030@194.163.189.114:46656,b61e8b2e7a658f544da87d264838e1b9db8f3736@146.19.24.52:30656,c56d227ed0cd0474d2797425462a8b508f20f7ab@65.108.137.92:26656,b11f7e034486bec2aa24d4cd3cfb0a320f16b4dd@65.109.32.85:55656,76aee087eeab69b7faa20dd4d168b9fe06220391@159.223.238.85:55656,557c41fffcbab57033e92c7a3c595f7822a1014e@38.242.148.59:26656,6a357c1afc6ba7209ad504a78e2e2bb075f667bc@38.242.197.31:55656,be385046ac405460b4939b7a303797813f4fc904@65.109.1.209:22656,cdded2b5faa0eaf1aa0770638d7202351d3eb123@176.9.146.72:55656,a1222dfb8641e0cb55615b75e0122d5695be1f35@34.171.67.167:26656,3c03522288066493d35849394786591bd34b7ba0@80.254.8.54:26656,20c7cc01eabbc76ecb88dc568c8629829b22740b@146.19.24.56:26656,7a891db83683aee4766cf05ae88c6114aeeac47b@157.90.225.108:26656,4e7c0d78786ed7a22c682a57d0b1d5577277aa53@149.102.134.38:10656,0cfb02d6df8ff6c62a9c6cce5d1f70aef0bb3d53@168.119.114.99:10656,352efa85c0004084f2b7a8b92bc037090c856ade@178.250.246.99:27656,ebafc5ee6632512d2913ac12e8566cb462404d6d@135.181.255.131:36656,410f69f7b2523dd84213aada1e5f84126e380831@149.102.139.54:26656,88727530b242f837533d263bc873ca19dc9f3072@89.179.33.100:26656,2d0fa671089f783cd0bf8c80fde5819fbdce5e69@38.242.222.253:26656,87075fbd11ebcdbc2e5ff8fe6ddc000e0615b4f9@77.121.209.191:10656,1bc81a01c2ab7beaddbce295bf8d30710d844cf0@195.3.222.161:30656,76049cf6c729a15a456a2343ccd2fe22f3728c93@154.53.56.176:26656,2e02d6909b1778ecd138ef0cb81c2e4256ed5015@173.212.223.37:10656,cf61285c6dd6373a0bf9041c6407bfc83f342ed3@45.84.138.218:10656,93468ebca2604030b19603a251b647b51a3b2153@38.242.241.111:26656,3518f857f10955a1d939387af94e6f027c5048ad@138.197.148.132:10656,e9127cf1d726c856e128d08220de948e84e175e1@62.171.171.50:10656,e5a3a013ba95c28181b90e0fb9554a1ee866e8fb@161.97.145.13:30656
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.Cardchain/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOIS_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NOIS_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOIS_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOIS_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOIS_PORT}660\"%" $HOME/.noisd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOIS_PORT}317\"%; s%^address = \":8080\"%address = \":${NOIS_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOIS_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOIS_PORT}091\"%" $HOME/.noisd/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.noisd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.noisd/config/app.toml


# reset
noisd tendermint unsafe-reset-all --home $HOME/.noisd
SNAP_RPC="https://nois-testnet-rpc.polkachu.com:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.noisd/config/config.toml



echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/noisd.service > /dev/null <<EOF
[Unit]
Description=nois
After=network-online.target

[Service]
User=$USER
ExecStart=$(which noisd) start --home $HOME/.noisd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable noisd
sudo systemctl restart noisd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u noisd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${NOIS_PORT}657/status | jq .result.sync_info\e[0m"
