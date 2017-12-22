# P4wnP1_nexmon_additions by MaMe82 (WiFi monitor + injection + AP + firmware-based KARMA attack)

This repository is part of the P4wnP1 project and holds pre-compiled Nexmon binaries. The binaries are build for Raspbian Stretch with Kernel `4.9.51+`.

Nexmon by [@seemoo-lab](https://github.com/seemoo-lab) (NexMon Team) is licensed under GNU General Public License v3.0. The sources used to compile could be found here:
~ ~https://github.com/seemoo-lab/nexmon/tree/934c7066819913687742aba217a1d75b98c1d883~ ~
https://github.com/mame82/nexmon/tree/bcm43430a1_KARMA

Custom source is used, till merged into nexmon main RePo. This adds in KARMA attack + AP support while having a monitor interface up.

By default the firmware / driver runs with monitor interface disable. To bring it up use:

`iw phyN interface add mon0 type monitor; ifconfig mon0 up`

where `phyN` has to be replaced by the name of the physical interface, which for example is shown by the following command:

`iw list`

Under normal circumstances it should be `phy0`


Having the monitor + injection capable interface up, means tools like airodump-ng or aireplay-ng could be used.



P4wnP1 is licensed GNU General Public License v3.0, source code is here:
https://github.com/mame82/P4wnP1


## Important note:

In current firmware version the ioctls have been changed. This means instead of nexutil, it is recommend
to use the code of `karmatool.py` to change the KARMA settings. The advantage is: every firmware option could
be changed, while a hostapd Access Point is running (and only if hostapd is running).
This allows adding custom SSIDs, enable KARMA beaconing a.k.a MANA_LOUD or disable everything ON-DEMAND !
The docs get updated on this, as soon as the firmware mod is done.

## Access Point mode with hostapd

### TL;TR 
To allow AP mode with hostapd, the **monitor interface has to be brought 
up (steps described above) before hostapd is started**.

### Hostapd knows two modes of operations:

1. Under normal circumstances the driver/firmware of a WiFi interface 
only communicates data frames to the userland. This excludes management 
and control frames. But to deal with stations trying to connect to an 
access point, hostapd needs to receive and send these management and 
control frames. This is because AP beacons, probe requests, authentication 
requests, association requests and others are transmitted as management 
frames. To solve this problem hostapd uses a monitor interface which is
able to send and receive raw 802.11 (a.k.a frame injection + monitor 
capability, to be more precise - radiotap headers are needed, too).
This again means, a WiFi interface working with hostapd has to provide
a monitor/injection interface along with a second interface which supports
AP mode.

2. For the other operation mode, hostapd doesn't need a dedicate monitor/
injection interface in addition to the needed AP interface (note: we are 
talking about multiple virtual interfaces on a single physical interface).
Instead the interface firmware/driver handles the station management and
communicates relevant events via callbacks to hostapd. 

### Example for clarification - Association Request:

I "mode 1" hostapd receives an association request as management frame
from the virtual monitor interface. If the station is allowed to associate,
a management frame with an asociation response is sent back via the same 
virtual interface (injection). Hostapd is now able to handle the associated 
station in its internal data structures and communication is done via the 
second virtual interface, which works in AP mode instead of monitor mode.

In "mode 2" the association frame is handled in the firmware of the WiFi
interface and hostapd is informed about the association via an event.

### What does this mean for the AP enabled nexmon firmware in conjuction with hostapd ?

When hostapd is started, the following thing happen:

**Step 1:** Check if WiFi interface supports Full Station Management in hardware ("mode 2").
If yes, bring up the AP in this mode else continue with next step!

**Step 2:** Try to bring up a monitor interface. If it works, bring up the AP in "mode 1",
else continue with next step.

**Step 3:** If neither one worked, fail over to "mode 2", bring up the AP and try to
let the hardware handle the station management, although the interface reported 
that it doesn't support this mode of operation.


Now, the legacy firmware for the BCM43430a1 handles Station Management in
hardware, but doesn't report this capability. This again means, that hostapd
runs through all 3 steps described above and ends up in the failover for
"mode 2".

The important part is, that the legacy driver reports "Erro Operation not
supported", when hostapd tries to bring up the monitor interface in step 2.
This again leads to the failover and everything works as intended.

With the "monitor enabled" patched nexmon firmware, this of course changes.
Now hostapd is able to bring up the monitor interface and tries to work 
in "mode 1". This works for communication of probe request/response and
authentication frames, but when it comes to association (which hostapd
tries to handle internally and inform the driver about its doings) it 
fails, because the firmware isn't aware of the station which tries to 
associate (because the firmware hasn't handle probing and authentication 
itself). This ultimately results in a disassociation, send by the firmware.
This again means, no station could connect to the spawned AP.

To overcome this issue, the brcmfmac driver has been modified in a manner
to report "error operation not supported" if the userland part tries to add
a monitor interface, but there's already a monitor interface up. This
exactly mimics the behavior of the umodified driver/firmware and leads
to the failover step 3 described above. **So the only thing which has to
be done in order to make hostapd work, is to bring up a monitor interface
before starting hostapd**. The nice thing about this, is that the monitor
interface could be used, while the AP is up and running. There's one logical
restriction with that: The channel of course couldn't be changed, hwen the 
AP is up.
	
## Hardware based KARMA attack (experimental, likely to change)

### TL;TR

To make KARMA work the following steps have to be done:

0. Install the provided firmware `brcmfmac43430-sdio.bin` and driver `brcmfmac.ko`
1. Bring up a monitor interface and afterwards a hostapd based **OPEN** 
access point (steps describe above)
2. Run `karmatool.py`  to change the firmware configuration (including KARMA,
custom SSIDs etc) as needed **while the AP is running**

To simply enable KARMA use `karmatool.py -k 1`

```
Usage:      python karmatool.py [Arguments]

Arguments:
   -h                   Print this help screen
   -i                   Interactive mode
   -d                   Load default configuration (KARMA on, KARMA beaconing off, 
                        beaconing for 13 common SSIDs on, custom SSIDs never expire)
   -c                   Print current KARMA firmware configuration
   -p 0/1               Disable/Enable KARMA probe responses
   -a 0/1               Disable/Enable KARMA association responses
   -k 0/1               Disable/Enable KARMA association responses and probe responses
                        (overrides -p and -a)
   -b 0/1               Disable/Enable KARMA beaconing (broadcasts up to 20 SSIDs
                        spotted in probe requests as beacon)
   -s 0/1               Disable/Enable custom SSID beaconing (broadcasts up to 20 SSIDs
                        which have been added by the user with '--addssid=' when enabled)
   --addssid="test"     Add SSID "test" to custom SSID list (max 20 SSIDs)
   --remssid="test"     Remove SSID "test" from custom SSID list
   --clearssids         Clear list of custom SSIDs
   --clearkarma         Clear list of karma SSIDs (only influences beaconing, not probes)
   --autoremkarma=600   Auto remove KARMA SSIDs from beaconing list after sending 600 beacons
                        without receiving an association (about 60 seconds, 0 = beacon forever)
   --autoremcustom=3000    Auto remove custom SSIDs from beaconing list after sending 3000
                        beacons without receiving an association (about 5 minutes, 0 = beacon
                        forever)
   
Example:
   python karmatool.py -k 1 -b 0    Enables KARMA (probe and association responses)
                                    But sends no beacons for SSIDs from received probes
   python karmatool.py -k 1 -b 0    Enables KARMA (probe and association responses)
                                    and sends beacons for SSIDs from received probes
                                    (max 20 SSIDs, if autoremove isn't enabled)
   
   python karmatool.py --addssid="test 1" --addssid="test 2" -s 1
                                    Add SSID "test 1" and "test 2" and enable beaconing for
                                    custom SSIDs
```


If everything works, every probe request for a former unknwon network
should be respond properbly and the client is magically allowed to
connect to the AP (which effectively doesn't exist).

Of course the AP hasn't got to use "Open Authentication System", but
this attacks doesn't make to much sense with an AP forcing authentication.

### Details on implementation

The initial idea was to use hostapd-mana by Sensepost (greetings to Dominic,
who would have allowed to use a precompiled version). Unfortunately this
didn't work out. The reason is partially deascribe above: hostapd couldn't
work in the operation mode, where it uses a dedicated monitor interface for
station handling. But, the KARMA patches of hostapd use exactly this monitor
interface (with injection capabilities) to carry out the attack, which
couldn't be made available to hostapd with the bcm43430a1 firmware.

There have been two options to overcome this:

1. Modify the complete driver/firmware stack of BCM43430a1 to emulate
the behavior of a WiFi interface which handles Station Management in software
("emulation" is the wrong word, as in fact one needs to implement station
management in software).

2. Reverse the Firmware, use nexmon framework to modify it and let the
hardware do the job.

To make a long story short (and avoid more TL;TR), option 2 was chosen.
You find the result in this repo as precompiled firmware + driver.
Everything is highly experimental, not widely tested and undergoing changes
(especially when it comes to debug output to the chips internal console).

~ ~There are some ToDo's, like allow beaconing for seen probes (the `mana_loud`
option in hostapd-mana).

For now only probe responses for seen requests are transmitted (and of course
association is handled correctly). As this is a firmware patch, everything
runs in hardware and thus - let's say - a bit faster than with hostapd-mana:
Probe requests are responded immediately (at least when I get rid of the
throttling debug prints to the internal console).

The main ToDo is to integrate everything into P4wnP1.~ ~

Current version allows sending beacons for seen probes (KARMA LOUD).
Additionally custom SSIDs could be added for beaconing and both,
karma and custom SSIDs, could automatically be removed if no association
request is received (user defined timeout).

Custom and KARMA SSIDs for beaoning are limited to 20, each. Probe and 
association responses are send back without such a limit.

## Shout out

In case somebody is working on a similar project, I'd be happy to see
a mod where the chip could be used to run in station mode and KARMA-enabled
AP mode at the same time.
Why ? Because this would allow to use a single chip for an upstream WiFi 
internet connection, while a KARMA Access Point is running ... and
hey, maybe it could be ported to Mobile Phones ;-)
