#!/bin/bash

currentDir=$( pwd )
namespace="cluster-api"

coreVersion="v1.9.7"
capmoxVersion="v0.7.2"
inClusterIPAMVersion="v1.0.2"
helmAddonVersion="v0.3.2"
carenVersion="v0.33.1"

function generateCoreProvider() {

  coreDir="components/core/$coreVersion"

  mkdir -p $coreDir

  clusterctl generate provider \
    --config clusterctl.yaml \
    --target-namespace $namespace \
    --core cluster-api:$coreVersion | \
    yq -y 'select(.kind != "Namespace")' > $coreDir/cluster-api.yaml

  clusterctl generate provider \
    --config clusterctl.yaml \
    --target-namespace $namespace \
    --bootstrap kubeadm:$coreVersion | \
    yq -y 'select(.kind != "Namespace")' > $coreDir/bootstrap.yaml

  clusterctl generate provider \
    --config clusterctl.yaml \
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
    --config clusterctl.yaml \
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
    --config clusterctl.yaml \
    --target-namespace $namespace \
    --ipam in-cluster:$inClusterIPAMVersion | \
    yq -y 'select(.kind != "Namespace")' > $ipamDir/ipam.yaml

  cd $ipamDir

  rm -f kustomization.yaml

  kustomize create --resources ipam.yaml

  cd $currentDir

}

function generateHelmAddonProvider() {

  helmDir="components/helm-addon/$helmAddonVersion"

  mkdir -p $helmDir

  clusterctl generate provider \
    --config clusterctl.yaml \
    --target-namespace $namespace \
    --addon helm:$helmAddonVersion | \
    yq -y 'select(.kind != "Namespace")' > $helmDir/helm.yaml

  cd $helmDir

  rm -f kustomization.yaml

  kustomize create --resources helm.yaml

  cd $currentDir

}

function generateCARENProvider() {

  carenDir="components/caren/$carenVersion"

  mkdir -p $carenDir

  clusterctl generate provider \
    --config clusterctl.yaml \
    --target-namespace $namespace \
    --runtime-extension caren:$carenVersion | \
    yq -y 'select(.kind != "Namespace")' > $carenDir/caren.yaml

  cd $carenDir

  rm -f kustomization.yaml

  kustomize create --resources caren.yaml

  cd $currentDir

}

function main() {

  generateCoreProvider

  generateProxmoxInfraProvider

  generateInClusterIPAMProvider

  generateHelmAddonProvider

  generateCARENProvider

}

main