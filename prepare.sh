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

GWIP=172.24.0.2
sudo route add -net default gw $GWIP

sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install git libgmp3-dev gawk qpdf bison flex make bc libncurses5-dev automake

# update kernel (one timer, reboot needed)
#sudo rpi-update # reboot needed after kernel image update

# install rpi-source (one timer)
#sudo wget https://raw.githubusercontent.com/notro/rpi-source/master/rpi-source -O /usr/bin/rpi-source && sudo chmod +x /usr/bin/rpi-source && /usr/bin/rpi-source -q --tag-update

sudo rpi-source --skip-gcc
