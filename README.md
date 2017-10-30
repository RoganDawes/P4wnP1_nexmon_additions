# P4wnP1_nexmon_additions

This repository is part of the P4wnP1 project and holds pre-compiled Nexmon binaries. The binaries are build for Raspbian Stretch with Kernel `4.9.51+`.

Nexmon by [@seemoo-lab](https://github.com/seemoo-lab) (NexMon Team) is licensed under GNU General Public License v3.0. The sources used to compile could be found here:
~ ~https://github.com/seemoo-lab/nexmon/tree/934c7066819913687742aba217a1d75b98c1d883~ ~
https://github.com/mame82/nexmon/tree/dual_interface_AP_mode

Custom source is used, till merged into nexmon main RePo. This adds in AP support while having a monitor interface up.

Mode 7 has been added: `nexutil -m7` doesn't bring up a monitor interface, but allows adding one. This means:

- `airmon-ng` could be used (throws an error but works). 
- `hostapd` succeeds in adding a monitor interface (not really needed and **shouldn't be used**)
- `hostapd-mana` succeeds in adding an monitor interface (this time it is needed, to carry out KARMA ATTACKS)


P4wnP1 is licensed GNU General Public License v3.0, source code is here:
https://github.com/mame82/P4wnP1

Note on hostapd:
----------------

The broadcom brcm43430a1 chipset of the Raspberry works with hostaps's nl80211 driver. 
In early versions of this driver, a dedicated monitor interface was used by hostapd to grab *probe request
frames* and send *beacon frames*.

Although this isn't needed on current drivers/firmware (there are special commands which fulfill this 
task without a dedicated monitpr interface), **hostapd tries to bring up a monitor interface**. 
If this doesn't succeed, hostapd fails over to a mode without monitor interface.

This results in different behavior of **legacy hostapd** and **hostapd-mana** (by Sensepost).

1. **legacy hostapd**: If hostapd is allowed to bring up the monitor interface, it doesn't fail over
to the "monitor-less" configuration. This resulted in a non working Access Point in all of my tests
(AP is visible, but clients aren't able to associate). Unfortunately there seems to be no configuration
option to disable the use of the monitor interface. To deal with this problem, I recommend to bring
up a Monitor interface, before starting hostapd. In result hostapd isn't able to add a second
monitor interface and fails over to the normal behavior. The established monitor interface could
be used afterwards, but is of course bound to the channel use by hostapd. The additional interface
could be added with standard commands (e.g `iw phy phyNN interface add mon0 type monitor` or 
`airmon-ng start wlanNN`) while usin `nexutil -m7` or by using `nexutil -m6`. The latter adds a monitor
interface by default.
2. **hostapd-mana** behaves differently: If a monitor interface is already present, the AP works as intended
(same as legacy hostapd). But the karma attack (`enable_mana=1`) doesn't work without a dedicated monitor
interface exclusivly available for hostapd-mana. So this time it has to be done the other way around:
In order to bring up a Karma capable AP, there mustn't already exist a monitor interface when starting
hostapd. This could be achieved by using `nexutil -m7` without adding the monitor interface. When
hostapd-mana is launched, the monitor interface is brought up automatically (and removed when hostapd is 
stopped). Frames with client probes could only be fetched and used to create the corresponding beacons
if hostapd-mana has spawned the needed monitor interface. Again, there seems to be no configuration
option to tell hostapd to use a pre-existing monitor interface for this purpose.

### Sumarry

In order to reliably use legacy hostapd, a monitor interface should already be up before starting it.
In order to reliably use hostapd-mana, there mustn't be a monitor interface up before starting it (but 
adding one has to be allowed - `nexutil -m7`).