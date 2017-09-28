#!/bin/bash


#    This file is part of P4wnP1.
#
#    Copyright (c) 2017, Marcus Mengs.
#
#    P4wnP1 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    P4wnP1 is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with P4wnP1.  If not, see <http://www.gnu.org/licenses/>.

function switch_nexmon()
{
	#backup-firmware
	if [ ! -f brcmfmac43430-sdio.bin.orig ]; then
		printf "\033[0;31m  BACKUP\033[0m of brcmfmac43430-sdio.bin written to $(pwd)/brcmfmac43430-sdio.bin.orig\n"
		cp /lib/firmware/brcm/brcmfmac43430-sdio.bin brcmfmac43430-sdio.bin.orig
	fi

	#install-firmware: brcmfmac43430-sdio.bin brcmfmac.ko
	printf "\033[0;31m  COPYING\033[0m brcmfmac43430-sdio.bin => /lib/firmware/brcm/brcmfmac43430-sdio.bin\n"
	cp brcmfmac43430-sdio.bin /lib/firmware/brcm/brcmfmac43430-sdio.bin

	if [ $(lsmod | grep "^brcmfmac" | wc -l) == "1" ]
	then
		printf "\033[0;31m  UNLOADING\033[0m brcmfmac\n"
	        sudo rmmod brcmfmac
	fi

	sudo modprobe brcmutil
	printf "\033[0;31m  RELOADING\033[0m brcmfmac\n"

	sudo insmod brcmfmac.ko
}

function switch_legacy()
{
	printf "\033[0;31m  COPYING\033[0m brcmfmac43430-sdio.bin.backup => /lib/firmware/brcm/brcmfmac43430-sdio.bin\n"
	cp brcmfmac43430-sdio.bin.backup /lib/firmware/brcm/brcmfmac43430-sdio.bin

	if [ $(lsmod | grep "^brcmfmac" | wc -l) == "1" ]
	then
		printf "\033[0;31m  UNLOADING\033[0m brcmfmac\n"
	        sudo rmmod brcmfmac
	fi

	sudo modprobe brcmutil
	printf "\033[0;31m  RELOADING\033[0m brcmfmac\n"

	sudo insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
}

switch_legacy
switch_nexmon
