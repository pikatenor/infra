# Register command for flannel host-gw

## etcd, control-plane, worker

    export $(cat /etc/default/k3s | xargs); INSTALL_K3S_EXEC="--node-ip $PRIVATE_IP --flannel-backend host-gw --flannel-iface $PRIVATE_DEVICE" curl -fL https://rancher.yuzu.p1kachu.net/system-agent-install.sh | sudo INSTALL_K3S_EXEC="--node-ip $PRIVATE_IP --flannel-backend host-gw --flannel-iface $PRIVATE_DEVICE" sh -s - --server https://rancher.yuzu.p1kachu.net --label 'cattle.io/os=linux' --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --etcd --controlplane --worker

## control-plane, worker

    export $(cat /etc/default/k3s | xargs); INSTALL_K3S_EXEC="--node-ip $PRIVATE_IP --flannel-backend host-gw --flannel-iface $PRIVATE_DEVICE" curl -fL https://rancher.yuzu.p1kachu.net/system-agent-install.sh | sudo INSTALL_K3S_EXEC="--node-ip $PRIVATE_IP --flannel-backend host-gw --flannel-iface $PRIVATE_DEVICE" sh -s - --server https://rancher.yuzu.p1kachu.net --label 'cattle.io/os=linux' --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --controlplane --worker


