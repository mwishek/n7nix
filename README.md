# Install scripts for some packet functionality

## Introduction

This repo contains scripts & notes for taking a new COMPASS image and
creating a working image that will boot up & run the following configurations:
* Core only
  * This includes [direwolf](https://github.com/wb2osz/direwolf/blob/master/README.md) & [AX.25](http://www.linux-ax25.org/wiki/Main_Page) with no other application
* RMS Winlink Gateway
* paclink-unix in two flavors
  * paclink-unix basic which allows using a movemail e-mail client like Thunderbird
  * paclink-unix imap which allows using any e-mail client that supports IMAP.

Note _deviation_ is stand alone and is not part of the install/config process.

Compass is a file system image for the Raspberry Pi that contains a
kernel with the driver for the Texas Instruments tlv320aic32x4 DSP
sound chip. Other than this codec driver the Compass image mimics the
[Raspbian image](https://www.raspberrypi.org/downloads/raspbian/).

The NW Digital Radio [UDRC
II](http://nwdigitalradio.com/wp-content/uploads/2012/04/UDRC-IIDS.pdf) is a
[hat](https://github.com/raspberrypi/hats) that contains the
tlv320aic32x4 DSP sound chip plus routes GPIO pins to control PTT. It also has
a 12V to 5V regulator so that you can run the Pi from a 12V supply.

Only the direwolf configuration is specific to the [UDRC II
hardware](http://nwdigitalradio.com/wp-content/uploads/2012/04/UDRC-IIDS.pdf)

## Installation scripts

### Core

**Core is required for any other packet apps using a UDRC**. This option
installs
[direwolf](https://github.com/nwdigitalradio/n7nix/tree/master/direwolf)
& [AX.25](https://github.com/nwdigitalradio/n7nix/tree/master/ax25)
tools/apps/library.  Use this option if you want to run APRS only or
some packet client that uses direwolf or AX.25. As part of the core
requirements this option also configures
[systemd](https://github.com/nwdigitalradio/n7nix/tree/master/systemd)
to start direwolf, AX.25 attach & AX.25 apps like mheardd at boot time.

Regardless of what functionality you want to install the first thing to run is
[core_install.sh](https://github.com/nwdigitalradio/n7nix/blob/master/CORE_INSTALL.md)
which will do the initial configuring of the compass kernel & install
AX.25 & direwolf.

### RMS Gateway

In order to install the Linux RMS Gateway you must register with Winlink to get a
password for a gateway.

See
[RMSGW_INSTALL.md](https://github.com/nwdigitalradio/n7nix/blob/master/RMSGW_INSTALL.md)
for details on installing RMS Gateway functionality.

See
[config/app_install.sh](https://github.com/nwdigitalradio/n7nix/tree/master/config/app_install.sh)
for installing all apps required for RMS Gateway.

### paclink-unix

* Two installation options:
  * basic -
  [installs paclink-unix, mutt & postfix](https://github.com/nwdigitalradio/n7nix/blob/master/PACLINK-UNIX_INSTALL.md)
  * imap -
  [installs the above plus, dovecot imap mailserver & hostapd](https://github.com/nwdigitalradio/n7nix/blob/master/PACLINK-UNIX-IMAP_INSTALL.md)
  WiFi access point, and dnsmasq to serve up DNS & DHCP when the RPi 3
  is not connected to a network.

#### paclink-unix basic

This is a light weight paclink-unix install that gives functionality
to use an e-mail client on the Raspberry Pi to compose & send winlink
messages

#### paclink-unix imap

This installs functionality to use any imap e-mail client & to access
paclink-unix from a browser. This allows using a WiFi device (smart
phone, tablet, laptop) to compose a Winlink message & envoke
paclink-unix to send the message.

Installs the following:

* [hostapdd](https://github.com/nwdigitalradio/n7nix/tree/master/hostap)
to enable WiFi for a Raspberry Pi 3
* [dovecot](https://github.com/nwdigitalradio/n7nix/tree/master/mailserv), imap e-mail server
* dnsmasq to allow connecting to the Raspbery Pi when it is not
connected to a network



### Other

#### [deviation](https://github.com/nwdigitalradio/n7nix/tree/master/deviation)

* Script that generates a tone file using sox, turns on correct PTT
gpio and plays wave file through a UDRC
* Generating a tone sine wave is one part of measuring deviation. The
other part is doing the actual measurement. The [Xastir
wiki](http://xastir.org/index.php/HowTo:Set_Deviation_via_RTL) has a
nice article on how to do that using an RTL SDR dongle.

#### [vnc](https://github.com/nwdigitalradio/n7nix/blob/master/vnc)

* systemd service file supplied by Ken Koster K7IPB.
