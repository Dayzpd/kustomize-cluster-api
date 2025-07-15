#!/bin/bash

currentDir=$( pwd )
namespace="cluster-api"

coreVersion="v1.9.7"
capmoxVersion="v0.7.1"
inClusterIPAMVersion="v1.0.2"

function generateCoreProvider() {

  coreDir="components/core/$coreVersion"

  mkdir -p $coreDir

  clusterctl generate provider \
    --target-namespace $namespace \
    --core cluster-api:$coreVersion | \
    yq -y 'select(.kind != "Namespace")' > $coreDir/cluster-api.yaml

  clusterctl generate provider \
    --target-namespace $namespace \
    --bootstrap kubeadm:$coreVersion | \
    yq -y 'select(.kind != "Namespace")' > $coreDir/bootstrap.yaml

  clusterctl generate provider \
    --target-namespace $namespace \
    --control-plane kubeadm:$coreVersion | \
    yq -y 'select(.kind != "Namespace")' > $coreDir/control-plane.yaml

  cd $coreDir

  rm -f kustomization.yaml

  kustomize create --resources cluster-api.yaml,bootstrap.yaml,control-plane.yaml

  cd $currentDir

}

function generateProxmoxInfraProvider() {

  infraDir="components/capmox/$capmoxVersion"

  mkdir -p $infraDir

  clusterctl generate provider \
    --target-namespace $namespace \
    --infrastructure proxmox:$capmoxVersion | \
    yq -y 'select(.kind != "Namespace")' > $infraDir/infrastructure.yaml

  cd $infraDir

  rm -f kustomization.yaml

  kustomize create --resources infrastructure.yaml

  cd $currentDir

}

function generateInClusterIPAMProvider() {

  ipamDir="components/in-cluster-ipam/$inClusterIPAMVersion"

  mkdir -p $ipamDir

  clusterctl generate provider \
    --target-namespace $namespace \
    --ipam in-cluster:$inClusterIPAMVersion | \
    yq -y 'select(.kind != "Namespace")' > $ipamDir/ipam.yaml

  cd $ipamDir

  rm -f kustomization.yaml

  kustomize create --resources ipam.yaml

  cd $currentDir

}

#clusterctl generate provider \
#  --target-namespace $namespace \
#  --addon helm | \
#  yq -y 'select(.kind != "Namespace")' > capi/providers/helm-addons.yaml

function main() {

  generateCoreProvider

  generateProxmoxInfraProvider

  generateInClusterIPAMProvider

}

main