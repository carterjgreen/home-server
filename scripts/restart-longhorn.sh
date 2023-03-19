#!/bin/bash

kubectl rollout restart daemonset engine-image-ei-7fa7c208 -n longhorn-system
kubectl rollout restart daemonset longhorn-csi-plugin -n longhorn-system
kubectl rollout restart daemonset longhorn-manager -n longhorn-system

kubectl rollout restart deploy csi-attacher -n longhorn-system
kubectl rollout restart deploy csi-provisioner -n longhorn-system
kubectl rollout restart deploy csi-resizer -n longhorn-system
kubectl rollout restart deploy csi-snapshotter -n longhorn-system
kubectl rollout restart deploy longhorn-driver-deployer -n longhorn-system
kubectl rollout restart deploy longhorn-ui -n longhorn-system
# My additions
kubectl rollout restart deploy longhorn-recovery-backend -n longhorn-system
kubectl rollout restart deploy longhorn-admission-webhook -n longhorn-system
kubectl rollout restart deploy longhorn-conversion-webhook -n longhorn-system