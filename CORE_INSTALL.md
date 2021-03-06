# CORE Functionality Install for UDRC

## Components of CORE

* direwolf
* AX.25 lib tools & apps
* systemd transactional files

## Functionality of CORE

* After CORE components are installed the following functionality is enabled
  * APRS
  * AX.25 packet spy
  * mheard

# Installing CORE functionality

## git a compass image

* Compass is a file system image for the Raspberry Pi that contains a kernel with the driver for the Texas Instruments tlv320aic32x4 Codec module.
* The NW Digital Radio UDRC II is a [hat](https://github.com/raspberrypi/hats) that contains this codec plus routes GPIO pins to control PTT.

* Download a Compass Linux image from http://archive.compasslinux.org/images
  * The 'lite' version is without a GUI
  * The full version has the LXDE Windows Manager & a graphic configuration tools for other stuff.
* Unzip and copy the uncompressed image to the SD card using the procedure outlined on the [Raspberry Pi site](https://www.raspberrypi.org/documentation/installation/installing-images/)
  * For example, see below:
    * **Note:** If you don't get the output device correct of=/dev/sdx you can ruin what ever you have installed on workstation hard drive
```bash
unzip image_2016_09-03-compass-lite.zip
dd if=2016-09-03-compass-lite.img of=/dev/sdc bs=4M
```

* To enable ssh on first boot mount flash drive & create ssh file in /boot partition
  * On debian systems this partition may get auto mounted on /media/`<user_name>`/boot
```bash
touch /media/<user_name>/boot/ssh
```
* Another way to enable ssh by creating ssh file in boot partition by manually mounting boot partition
  * The x in sdx1 is a letter you must accuartely determine
```
mount /dev/sdx1 /media/sd
# Verify that you have in fact mounted the boot partition
touch /media/sd/ssh
umount /media/sd
```

## first boot
* **Make sure Ethernet cable is plugged into a working network**
* Power up, find IP address assigned to this device
  * It can take several minutes to boot up on the initial boot because the file system is being expanded.
  * Be patient.

#### Note if you get this message on your host machine
```
$ ssh pi@<rpi_ip_address>
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
```
* go into your workstation .ssh directory, remove the known_hosts file & try again
```bash
cd .ssh
rm known_hosts
```
* Now ssh into your RPi ...
```bash
ssh pi@<rpi_ip_address>
```

* and do the following:

```bash
sudo su
apt-get update
# Be patient, the following command will take some time
# Also you may get a (q to quit) prompt to continue after reading about sudoers
# list. Just hit 'q'
apt-get upgrade -y
# Just copy & paste the following line into your ssh console
apt-get install -y mg jed rsync build-essential autoconf automake libtool git libasound2-dev whois libncurses5-dev
# reboot
shutdown -r now
```
## after reboot
* relogin as same user (probably pi) and execute the following commands.

```bash
git clone https://github.com/nwdigitalradio/n7nix
cd n7nix/config
sudo su
./core_install.sh
```

* You may be asked to change your password
* You will be prompted to change hostname & set your time zone.
* note: When changing time zone type first letter of location,
  * ie. (A)merica, (L)os Angeles
  * then use arrow keys to make selection
* **When any choices appear on terminal just hit return**
  * ie. for /etc/ax25/axports nrports & rsports

#### Core Configuration

* Part of core install is configuration of ax25, direwolf & systemd.
* You will be required to supply the following:
  * Your callsign
  * SSID used for direwolf APRS (recommend 1)
* When the script finishes & you see:

```
core configuration FINISHED

app install (core) script FINISHED
```

the new RPi image has been initialized and AX.25 & direwolf are
installed.
* **reboot again**
```bash
# reboot
shutdown -r now
```

## After CORE install

* Core provides APRS & AX.25 packet functionality so you can either
test & verify this functionality or continue on to install one of the
following.

  * [RMS Gateway](RMSGW_INSTALL.md)
  * [paclink-unix](PACLINK-UNIX_INSTALL.md)
  * [paclink-unix with IMAP server](PACLINK-UNIX-IMAP_INSTALL.md)

### How to Enable Serial console

* To Enable a serial console on a Raspberry Pi 3 change 2 files
  * Disable bluetooth in /boot/config.txt
```
dtoverlay=pi3-disable-bt
```
  * Specify serial console port in /boot/cmdline.txt
    * Change console=serial0 to console=ttyAMA0,115200

## Verifying CORE Install
### Testing direwolf & the UDRC
#### Monitor Receive packets from direwolf
* Open a console to the pi and type:
```bash
tail -f /var/log/direwolf/direwolf.log
```
* Tune your radio to the 2M 1200 baud APRS frequency 144.390 or some frequency known to have packet traffic
  * You should now be able to see the packets decoded by direwolf

#### Check status of all AX.25 & direwolf processes started with systemd
* Open another console window to the pi and as user pi type:
```bash
cd ~/bin
./ax25-status
```
#### Verify version of Raspberry Pi, UDRC,

* There are 3 other progams in the bin directory that confirm that the installation went well.
  * While in local bin directory as user pi
```bash
cd ~/bin
./piver.sh
./udrcver.sh
```

#### check ALSA soundcard enumeration
  * While in local bin directory as user pi
```bash
cd ~/bin
./sndcard.sh
```

### Testing AX.25

* In a console type:
```bash
netstat --ax25
```
* You should see a list of open listening sockets that looks something like this:
```
Active AX.25 sockets
Dest       Source     Device  State        Vr/Vs    Send-Q  Recv-Q
*          N7NIX-10   ax0     LISTENING    000/000  0       0
*          N7NIX-2    ax0     LISTENING    000/000  0       0
```
* In another console type:
  * You need to run the _listen_ program as root
```bash
sudo su
listen -at
```
* Over time you should see packets scrolling up the screen

* In a console type:
```bash
mheard
```
* You should see something like this:
```
Callsign  Port Packets   Last Heard
VE7RYF-8   udr0      7   Thu Nov 10 14:04:20
VE7RYF     udr0      3   Thu Nov 10 14:03:01
VE7CRP-8   udr0      5   Thu Nov 10 14:01:59
VE7CRD-8   udr0      7   Thu Nov 10 14:00:45
VE7AVV-8   udr0      3   Thu Nov 10 14:00:12
VE7AVV     udr0      1   Thu Nov 10 14:00:12
VA7VOP     udr0      2   Thu Nov 10 13:59:56
VE7CRD     udr0      2   Thu Nov 10 13:59:37
VA7BLD-8   udr0      6   Thu Nov 10 13:59:28
VA7BLD     udr0      2   Thu Nov 10 13:59:27
VE7WOD-8   udr0      6   Thu Nov 10 13:58:33
VE7SOK-8   udr0      5   Thu Nov 10 13:57:42
VE7SOK     udr0      2   Thu Nov 10 13:57:41
VE7CRP     udr0      1   Thu Nov 10 13:51:59
PBBS       udr0      1   Thu Nov 10 13:38:33
VE7SPR-8   udr0      1   Thu Nov 10 13:38:23
VE7XPL-9   udr0     42   Thu Nov 10 13:29:57
WB4KGY-3   udr0      1   Thu Nov 10 13:29:52
N7NIX-3    udr0      2   Thu Nov 10 13:29:17
N7NIX-10   udr0    277   Thu Nov 10 13:26:56
N7NIX      udr0    184   Thu Nov 10 13:26:49
VE7GEL-10  udr0      1   Thu Nov 10 13:18:28
WA7EBH-15  udr0      4   Thu Nov 10 13:18:18
VA7MAS     udr0     13   Thu Nov 10 13:17:48
VE7WOL-9   udr0     26   Thu Nov 10 13:17:45
W7COA-9    udr0     30   Thu Nov 10 13:17:40
K7KCA-3    udr0      3   Thu Nov 10 13:17:33
VA7DRW-9   udr0      5   Thu Nov 10 13:17:29
VA7BUG-9   udr0      1   Thu Nov 10 13:16:47
VE7RYF-10  udr0      8   Thu Nov 10 13:16:18
```
