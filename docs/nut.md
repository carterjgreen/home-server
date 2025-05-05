# NUT Configuration and Notes

## Configuration

TBD section

## CPU stuck at 100%

[Main Issue](https://github.com/networkupstools/nut/pull/1965)
[Solution Reference](https://unix.stackexchange.com/a/253866)

Fixed in v2.8.1 of nut-client which is not included in Debian Bookworm. You must update to Debian Trixie to get v2.8.1.

Create `/etc/apt/sources.list.d/trixie.list` and add `deb http://deb.debian.org/debian trixie main`

Add preferences to `/etc/apt/preferences.d/trixie.pref`

```text
Package: *
Pin: release n=trixie
Pin-Priority: -10

Package: nut nut-server nut-client libupsclient6t64 libnutscan2
Pin: release n=trixie
Pin-Priority: 501
```

Then run `apt update` and `apt upgrade`

> EDIT: NVM libc6 is too hefty to update and I don't want to mess up my Proxmox installation. Debian Trixie will fix this. The [hard freeze](https://wiki.debian.org/DebianTrixie) will be on 2025-05-15 and Proxmox follows pretty quickly after.
