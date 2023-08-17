#!/bin/bash

export RUST_VERSION="1.67.1"
export BUSYBOX_IMAGE="busybox:1.35.0"
export CONFIG_DOCKERHUB="datenlord-deploy.yaml"
export CONFIG_MINIKUBE="scripts/datenlord_minikube.yaml"
export CONFIG_KIND="scripts/datenlord.yaml"
export CONTROLLER_APP_LABEL="csi-controller-datenlord"
export CONTROLLER_CONTAINER_NAME="datenlord-controller-plugin"
export CSI_ATTACHER_IMAGE="quay.io/k8scsi/csi-attacher:v2.2.0"
export CSI_DRIVER_IMAGE="quay.io/k8scsi/csi-node-driver-registrar:v1.3.0"
export CSI_PROVISIONER_IMAGE="quay.io/k8scsi/csi-provisioner:v1.6.0"
export CSI_RESIZER_IMAGE="quay.io/k8scsi/csi-resizer:v0.5.0"
export CSI_SNAPSHOTTER_IMAGE="quay.io/k8scsi/csi-snapshotter:v2.1.1"
export DATENLORD_CSI_IMAGE="datenlord/csiplugin:e2e_test"
export DATENLORD_IMAGE="datenlord/datenlord:e2e_test"
export DATENLORD_LOGGING="scripts/datenlord-logging.yaml"
export DATENLORD_LOGGING_NAMESPACE="datenlord-logging"
export DATENLORD_METRICS_TEST="scripts/datenlord-metrics-test.yaml"
export DATENLORD_MONITORING="scripts/datenlord-monitor.yaml"
export DATENLORD_MONITORING_NAMESPACE="datenlord-monitoring"
export DATENLORD_NAMESPACE="csi-datenlord"
export E2E_TEST_CONFIG="scripts/datenlord-e2e-test.yaml"
export ELASTICSEARCH_LABEL="elasticsearch"
export ETCD_IMAGE="gcr.io/etcd-development/etcd:v3.4.13"
export FUSE_CONTAINER_NAME="datenlord-async"
export FUSE_MOUNT_PATH="/var/opt/datenlord-data"
export GRAFANA_LABEL="grafana"
export GRAFANA_PORT="3000"
export K8S_CONFIG="k8s.e2e.config"
export K8S_VERSION="v1.21.1"
export KIBANA_LABEL="kibana"
export KIND_NODE_VERSION="kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6"
export KIND_VERSION="v0.11.1"
# export MINIKUBE_VERSION="v1.13.0"
export NODE_APP_LABEL="csi-nodeplugin-datenlord"
export NODE_CONTAINER_NAME="datenlord"
export PROMETHEUS_LABEL="prometheus-server"
export SCHEDULER_IMAGE="k8s.gcr.io/kube-scheduler:v1.19.1"
export SNAPSHOTTER_VERSION="v5.0.0"

NODES_IP="$(kubectl get nodes -A -o wide | awk 'FNR > 2 {print $6}')"
NODES="$(kubectl get nodes -A -o wide | awk 'FNR > 2 {print $1}')"
for node in ${NODES}; do
USER="$(whoami)"
#docker cp /etc/apt/sources.list ${node}:/etc/apt/sources.list
docker cp /tmp/sources.list ${node}:/etc/apt/sources.list
docker exec ${node} apt-get update
docker exec ${node} apt-get install -y ssh sudo
docker exec ${node} systemctl start sshd
docker exec ${node} useradd -m ${USER}
docker exec ${node} usermod -aG sudo ${USER}
echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /tmp/${USER}
docker cp /tmp/${USER} ${node}:/etc/sudoers.d/${USER}
docker exec ${node} chown root:root /etc/sudoers.d/${USER}

docker exec ${node} mkdir /home/${USER}/.ssh
docker exec ${node} ls -al /home/${USER}/
docker cp ${HOME}/.ssh/id_rsa.pub ${node}:/home/${USER}/.ssh/authorized_keys
docker exec ${node} chown ${USER}:${USER} /home/${USER}/ -R
done
for ip in ${NODES_IP}; do
    ssh-keyscan -H $ip >> ${HOME}/.ssh/known_hosts
done