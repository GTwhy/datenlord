#!/bin/bash
source ./load_envs.sh
# 定义镜像列表
images=(
"$ETCD_IMAGE"
"$BUSYBOX_IMAGE"
"$SCHEDULER_IMAGE"
"$CSI_ATTACHER_IMAGE"
"$CSI_DRIVER_IMAGE"
"$CSI_PROVISIONER_IMAGE"
"$CSI_RESIZER_IMAGE"
"$CSI_SNAPSHOTTER_IMAGE"
)

# 对每个镜像进行处理
for image in "${images[@]}"; do
  # 检查镜像是否已经在本地存在
  if ! docker image inspect "$image" > /dev/null 2>&1; then
    # 如果镜像不存在，则从 Docker Hub 拉取
    docker pull "$image"
  fi
  # 将镜像加载到 kind 集群中
  kind load docker-image "$image"
done

kind load docker-image $DATENLORD_IMAGE
kubectl cluster-info
kubectl get pods -A
kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml

echo "apply -f $CONFIG_KIND"
kubectl apply -f datenlord.yaml
# kubectl wait --for=condition=Ready pod -l app=csi-controller-datenlord -n csi-datenlord --timeout=60s
# kubectl wait --for=condition=Ready pod -l app=csi-nodeplugin-datenlord -n csi-datenlord --timeout=60s
kubectl wait --for=condition=Ready pod -l app=$CONTROLLER_APP_LABEL -n $DATENLORD_NAMESPACE --timeout=60s
kubectl wait --for=condition=Ready pod -l app=$NODE_APP_LABEL -n $DATENLORD_NAMESPACE --timeout=60s
FOUND_PATH=`cat /proc/self/mountinfo | grep fuse | grep $FUSE_MOUNT_PATH | awk '{print $5}'`
test -n "$FOUND_PATH" || (echo "FAILED TO FIND MOUNT PATH $FUSE_MOUNT_PATH" && /bin/false)
kubectl get pods -A -o wide