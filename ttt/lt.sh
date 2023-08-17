#!/bin/bash

source config.sh

# Create Kind Cluster
./create_kind_cluster.sh

# Setup SSH
./setup_ssh_for_cluster_nodes.sh

# Datenlord Monitoring and Alerting Test
sh scripts/datenlord_monitor_test.sh

# Deploy DatenLord to K8S
./deploy_datenlord_to_k8s.sh

# Datenlord metric and logging test
sh scripts/datenlord_metrics_logging_test.sh

# CSI E2E Test
./csi_e2e_test.sh

# DatenLord Perf Test
# TODO: avoid to re-create cluster
kind delete cluster
kind create cluster --config ./kind-config.yaml
kind load docker-image ${DATENLORD_IMAGE}
sh scripts/datenlord_perf_test.sh

# # Print DatenLord logs
# echo "check disk usage"
# df -h

# kubectl get pods -A -o wide
# CONTROLLER_POD_NAME=`kubectl get pod -l app=$CONTROLLER_APP_LABEL -n $DATENLORD_NAMESPACE -o jsonpath="{.items[0].metadata.name}"`
# echo "SHOW LOGS OF $CONTROLLER_CONTAINER_NAME IN $CONTROLLER_POD_NAME"
# kubectl logs $CONTROLLER_POD_NAME -n $DATENLORD_NAMESPACE -c $CONTROLLER_CONTAINER_NAME
# NODE_POD_NAMES=`kubectl get pods --selector=app=${NODE_APP_LABEL} --namespace ${DATENLORD_NAMESPACE} --output=custom-columns="NAME:.metadata.name" | tail -n +2`
# for pod in ${NODE_POD_NAMES}; do
#   echo "SHOW LOGS OF $NODE_CONTAINER_NAME IN ${pod}"
#   kubectl logs ${pod} -n ${DATENLORD_NAMESPACE} -c ${NODE_CONTAINER_NAME}
# done
# kubectl describe pod metrics-datenlord-test
# kubectl cluster-info dump