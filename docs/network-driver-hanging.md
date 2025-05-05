# Intel E1000 Driver Issues

[Main reference](https://forum.proxmox.com/threads/intel-nic-e1000e-hardware-unit-hang.106001/)

1. `ethtool -k eno2 | grep offload`
1. `cat /etc/network/interfaces`
1. `/sbin/ethtool -K eno2 tso off gso off`

Edit `/etc/network/interfaces` to include

```text
iface eno2 inet manual
  post-up /sbin/ethtool -K eno2 tso off gso off
```
