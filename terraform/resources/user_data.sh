#!/bin/bash

# Kubernetes Variable Declaration
KUBERNETES_VERSION="v1.30"
RUNC_VERSION="v1.1.12"
CNI_VERSION="v1.5.0"
CONTAINERD_VERSION="1.7.14"
KUBERNETES_INSTALL_VERSION="1.30.0-1.1"

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter


cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo "*****************Initial configuration completion*****************"

curl -LO https://github.com/containerd/containerd/releases/download/v$CONTAINERD_VERSION/containerd-$CONTAINERD_VERSION-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-$CONTAINERD_VERSION-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mkdir -p /usr/local/lib/systemd/system/
mv containerd.service /usr/local/lib/systemd/system/
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable --now containerd


curl -LO https://github.com/opencontainers/runc/releases/download/$RUNC_VERSION/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

echo "*****************Runtimes configured*****************"

curl -LO https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-linux-amd64-$CNI_VERSION.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-$CNI_VERSION.tgz


curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list


apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg kubelet="$KUBERNETES_INSTALL_VERSION" kubeadm="$KUBERNETES_INSTALL_VERSION" kubectl="$KUBERNETES_INSTALL_VERSION" --allow-downgrades --allow-change-held-packages
apt-mark hold kubelet kubeadm kubectl

crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock

echo "*****************Default configuration completion*****************"
