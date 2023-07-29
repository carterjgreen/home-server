Run after creation
```
Backup
mkdir uptime-base
kubectl cp uptimekuma-deployment-<name>:/app/data uptime-base

Restore
kubectl cp uptime-base uptimekuma-deployment-<name>:/app/data
```