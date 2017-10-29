# P4wnP1_nexmon_additions

This repository is part of the P4wnP1 project and holds pre-compiled Nexmon binaries. The binaries are build for Raspbian Stretch with Kernel `4.9.51+`.

Nexmon by [@seemoo-lab](https://github.com/seemoo-lab) (NexMon Team) is licensed under GNU General Public License v3.0. The sources used to compile could be found here:
~ ~https://github.com/seemoo-lab/nexmon/tree/934c7066819913687742aba217a1d75b98c1d883~ ~
https://github.com/mame82/nexmon/tree/dual_interface_AP_mode

Custom source is used, till merged into nexmon main RePo. This adds in AP support while having a monitor interface up.

Mode 7 has been added: `nexutil -m7` doesn't bring up a monitor interface, but allows adding one. This means:

- `airmon-ng` could be used (throws an error but works). 
- `hostapd` succeeds in adding a monitor interface (not really needed)
- `hostapd-mana` succeeds in adding an monitor interface (this time it is needed, to carry out KARMA ATTACKS)



P4wnP1 is licensed GNU General Public License v3.0, source code is here:
https://github.com/mame82/P4wnP1

