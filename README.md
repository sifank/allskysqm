# allskysqm

See the wiki on this site (above) for all information.

Below is kept here for reference:
Sky quality allsky cam based on Aaron's indi-allsky


Kahale Observatory: FieldSQM

    ​Reference to Aaron's INDI-AllSky Wiki
        Scroll down on bottom right and click for 12 more topics ... 

Notes:

    Wifi Hotspot: allskysqm
    Web site: ​https://allskysqm.local
        Public page: ​https://allskysqm.local/public 
    Optionally you can ssh to connect: ​sqm@allskysqm.local
        Login: sqm/allskysqm 
    Optionally you can vnc: vncviewer allskysqm:1
        Passwd: allskysqm 

Projected use sequence:

    Apply power and wait ~1 min for startup
    Connect to WiFi hotspot:
        allskysqm/allskysqm 
    Connect to sqm web pages:
        ​https://allskysqm/ or ​https://allskysqm.local/ or ​https://192.168.10.1/tps://allskysqm/ or ​https://allskysqm.local/ or ​https://192.168.10.1/
        Note: first time it will complain about the certificate, scroll down and answer yes to accept and probably yes again
        Login: admin/allskysqm 
    Wait for a current image on the 'Latest' page, refresh as needed
    Enter location and observer on 'Config' page in the FITs fields
    Verify settings
        Exposure time: Latest Image page will show gain, ccd temp, time, lat/long and sensor data
        Gain: Config page/Night Gain (121)
        GPS: Config page/GPS Time Sync (off)
            InfoBox? (bottom left corner) will show current GPS status and current long/lat 
        Offset: Config page/INDI Camera Configuration (Offset: 10)
        Cooling: Config page/CCD Cooling, on/Target CCD Temp (-10) 
    Purge all files (depending on use case)
        Web/System/Utilities/Flush Images and Flush Timelapses 
    Verify disk space
        Web/System/Info 
    Run for ~5 to 10 mins
        Review images and adjust or reposition in field as necessary
            Web/Latest 
    Review images and select best
        Web/Images, use the top bar to select and view images
        Use the 'Fits' button on the bottom of this page to transfer an image
            You can also use vnc or take out the sim and read it from a desktop, etc
                Images are located at: /var/www/html/allsky/images/ under a dated folder, then either a night or day folder, then a date_hour folder. They are time stamped. 
    Shutdown via 'System/Utilities?' web page
        Wait 5 mins before removing power 

Notes:

    Pages do not update/refresh right away, you may need to manually refresh the page
    Optionally you can ssh to connect: ssh ​sqm@allskysqm.local or ssh sqm@192.168.10.1
        Login: sqm/allskysqm 
    Public page: ​https://allskysqm.local/public or ​https://192.168.10.1/public
    How to take darks
        could take hours !
        Cover lens, ideally in a dark room or area and also covered with dark material

        systemctl --user stop indi-allsky
        cd /opt/indi-allsky
        source virtualenv/indi-allsky/bin/activate
        ./darks.py sigmaclip

    According to manual and advice, gain s/b 121 and offset s/b 10 

Useful utilites

    envStatus # displays all sensors, gives warnings if one is not responding
    fitsheader [filename] # to manually list a fits file's headers
    fitslist # lists all fits files under the web dir 

ISSUES:

    Enhancement Ability to set the exposure time (no auto adjust)
    Enhancement Eliminate the exposure time cap
    Enhancement Change text and background colors on UI to be more readable
    Done After manual time set, allsky spins on camera BUSY: using an RTC now
    DONE At dusk and dawn, kernel gets out of memory error and kills indi-allsky
        Must enable time-lapse in config 
    IN RELEASE Bullet proof the gps routines
        Don't enable GPS on the Config page, using RTC instead 
    DONE Place sqm config fields at the top of the page: config broken out to several tabs
    DONE Figure out how to do darks
    DONE Add system io wait time to system status page
    DONE Remove all other filesystem, only keep stats for / and /boot
    DONE In Config, add field for observer and location names
    DONE Add fields to fits header: lat, long, env temp, hum, dp, skytemp, pres, location, observer, # stars and jSQM value
    DONE Fix web page 'delete all image' to actually delete all images (delete fits) !
    DONE Add capability to download fits images from Image page
    DONE Have webpage get gps info (lat, long and time) from GPS
    DONE Add vnc server
    DONE Does this always keep the gain set in config? Yes
    DONE Set home page to public. Don't do this for our application
    DONE How to set the offset? Use INDI-config, see below
    DONE Superuser credentials got hosed. Need to figure out how to recoup or rebuild.
    DONE If cam cooling pwr is not connected, setting the cam temp will crash allsky software
        Set cooling temp in the Config page, set cooling ramp in the Config page under INDI Config (bottom)
        It will crash if your camera does not have cooling and you have it enabled. 
    DONE Add summary (gps and # fits files) to infobox 

Building the allskysqm
Setup initial networking

Using server only: ubuntu-22.04.1-preinstalled-server-arm64+raspi.img
apt -y install net-tools openssh-server
ifconfig #note address

sudo scp sifan@192.168.1.15:/etc/hosts /etc/

bashrc

scp kanto:.bashrc .
vi .bashrc   # remove the last line (conda) and comment out the BLINKA line
. .bashrc
sudo cp /home/sifan/.bashrc /root/

Update to full vi

apt-get update
apt-get install apt-file
apt-file update
apt-get install vim

    Options for .vimrc file

    set number
    set hlsearch
    set incsearch
    set ignorecase
    set smartcase
    set titlestring=%t

update

apt update
apt -y full-upgrade
apt autoremove
apt autoclean

setup hotspot

nmcli d wifi hotspot ifname wlan0 ssid sqm password allskysqm

    Modify /etc/NetworkManager/system-connections/Hotspot.nmconnection - set: autoconnect=true 

PCF8523 RTC

    Verify i2c device 0x68 exists
    Verify pcf8523 module exists, then add to dtoverlay devices

    sudo modprobe rtc-pcf8523
    sudo echo pcf8523 0x68 > /sys/class/i2c-adapter/i2c-1/new_device

    Verify i2c device 0x68 is now set to 'UU'

    hwclock -r or hwclock --show #see what it's currently set to
    hwclock --set --date="2023-04-15 23:23:00" # manually set it

    Repeat the read to verify it's set
    vi /lib/udev/hwclock-set set it to the following:

    #!/bin/sh
    # Reset the System Clock to UTC if the hardware clock from which it
    # was copied by the kernel was in localtime.

    dev=$1

    # if [ -e /run/systemd/system ] ; then
    #    exit 0
    # fi

    if [ -e /run/udev/hwclock-set ]; then
        exit 0
    fi

    if [ -f /etc/default/rcS ] ; then
        . /etc/default/rcS
    fi

    # These defaults are user-overridable in /etc/default/hwclock
    BADYEAR=no
    HWCLOCKACCESS=yes
    HWCLOCKPARS=
    HCTOSYS_DEVICE=rtc0
    if [ -f /etc/default/hwclock ] ; then
        . /etc/default/hwclock
    fi

    if [ yes = "$BADYEAR" ] ; then
        # /sbin/hwclock --rtc=$dev --systz --badyear
        /sbin/hwclock --rtc=$dev --hctosys --badyear
    else
        # /sbin/hwclock --rtc=$dev --systz
        /sbin/hwclock --rtc=$dev --hctosys
    fi

    Add to /boot/firmware/config.txt

    # for 8523 rtc
    dtoverlay=i2c-rtc,pcf8523,addr=0x68

    Reboot and check the time with hwclock --show
    If this works then add to root's crontab:

    # Set the system clock to the RTC
    @reboot /usr/sbin/hwclock --hctosys

    To remove new_device:

    cat /dev/null > ./devices/platform/soc/fe804000.i2c/i2c-1/new_device
    reboot

GPS

    Using Ultimate GPS hat
    apt install pps-tools gpsd gpsd-clients chrony
    vi /boot/firmware/cmdline.txt
        remove console=tty1

        zswap.enabled=1 zswap.zpool=z3fold zswap.compressor=zstd dwc_otg.lpm_enable=0 root=LABEL=writable rootfstype=ext4 rootwait fixrtc quiet splash

    Disable bluetooth:

    sudo systemctl disable hciuart.service
    sudo systemctl disable bluealsa.service
    sudo systemctl disable bluetooth.service

    Add to [All] in /boot/firmware/config.txt

    # for chrony and gps
    enable_uart=1
    init_uart_baud=9600
    dtoverlay=pps-gpio, gpiopin=4

    vi /etc/default/gpsd

    # Devices gpsd should collect to at boot time.
    # They need to be read/writeable, either by user gpsd or the group dialout.
    DEVICES="/dev/ttyS0 /dev/pps0"

    START_DAEMON="true"

    # Other options you want to pass to gpsd
    GPSD_OPTIONS="-n -b"

    # Automatically hot add/remove USB GPS devices via gpsdctl
    #USBAUTO="true"

    vi /etc/chrony/chrony.conf

    # Welcome to the chrony configuration file. See chrony.conf(5) for more
    # information about usable directives.

    # Include configuration files found in /etc/chrony/conf.d.
    confdir /etc/chrony/conf.d

    #added for gps
    #refclock SHM 0 poll 0 refid GPS precision 1e-1 offset 0.055
    #refclock PPS /dev/pps0 lock GPS poll 0 refid PPS precision 1e-9
    refclock SHM 0 refid NMEA offset 0.200
    refclock PPS /dev/pps0 refid PPS lock NMEA

    # - 4 sources from ntp.ubuntu.com which some are ipv6 enabled
    # This will use (up to):
    # - 2 sources from 2.ubuntu.pool.ntp.org which is ipv6 enabled as well
    # - 1 source from [01].ubuntu.pool.ntp.org each (ipv4 only atm)
    # This means by default, up to 6 dual-stack and up to 2 additional IPv4-only
    # sources will be used.
    # At the same time it retains some protection against one of the entries being
    # down (compare to just using one of the lines). See (LP: #1754358) for the
    # discussion.
    #
    # About using servers from the NTP Pool Project in general see (LP: #104525).
    # Approved by Ubuntu Technical Board on 2011-02-08.
    # See http://www.pool.ntp.org/join.html for more information.
    #pool ntp.ubuntu.com        iburst maxsources 4
    #pool 0.ubuntu.pool.ntp.org iburst maxsources 1
    #pool 1.ubuntu.pool.ntp.org iburst maxsources 1
    #pool 2.ubuntu.pool.ntp.org iburst maxsources 2

    # Use time sources from DHCP.
    sourcedir /run/chrony-dhcp

    # Use NTP sources found in /etc/chrony/sources.d.
    sourcedir /etc/chrony/sources.d

    # This directive specify the location of the file containing ID/key pairs for
    # NTP authentication.
    keyfile /etc/chrony/chrony.keys

    # This directive specify the file into which chronyd will store the rate
    # information.
    driftfile /var/lib/chrony/chrony.drift

    # Save NTS keys and cookies.
    ntsdumpdir /var/lib/chrony

    # Uncomment the following line to turn logging on.
    #log tracking measurements statistics

    # Log files location.
    logdir /var/log/chrony

    # Stop bad estimates upsetting machine clock.
    maxupdateskew 100.0

    # This directive enables kernel synchronisation (every 11 minutes) of the
    # real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
    rtcsync

    # Step the system clock instead of slewing it if the adjustment is larger than
    # one second, but only in the first three clock updates.
    makestep 1 3

    # Get TAI-UTC offset and leap seconds from the system tz database.
    # This directive must be commented out when using time sources serving
    # leap-smeared time.
    leapsectz right/UTC

    check pps (could not get this to work

    systemctl restart chrony
    chronyc sources
    lsmod | grep pps
    ppstest /dev/pps0  # gets timeouts

    enable for reboot:
        systemctl enable gpsd.socket
        systemctl start gpsd.socket 
    reboot 

    commands to test/list:
        cgps or gpsmon 

    GPS start script (not needed now) 

Setup KOBS

mkdir /opt/KOBS
apt -y install i2c-tools  python3-rpi.gpio python3-smbus kate python3-pip locate
pip3 install adafruit-circuitpython-hts221 adafruit-circuitpython-ms8607 adafruit-circuitpython-htu31d adafruit-circuitpython-tsl2591 adafruit-blinka astropy hidapi psutil

    Modify /etc/group, add sqm to dialout group 

Add envParams to txt file for allsky display

    as root

    mkdir /opt/KOBS/allskyscripts; cd /opt/KOBS/allskyscripts
    touch allskytxt

    create /opt/KOBS/allskyscritps/allskyupdater 

crontab

    run: sudo crontab -e

    # m h  dom mon dow   command

    # Set the system clock to the RTC
    @reboot /usr/sbin/hwclock --hctosys

    # Every 2 min update stats for allsky image
    */2 * * * * /opt/KOBS/allskyscripts/allskyupdater > /opt/KOBS/allskyscripts/allsky.txt

    # Every 2 min update info box info
    */2 * * * * /opt/KOBS/allskyscripts/infoboxupdater > /opt/KOBS/allskyscripts/infobox.html

Create swap file

swapon --show
fallocate -l 1G /root/swapfile
chmod 600 /root/swapfile 
mkswap swapfile 
swapon /root/swapfile
vi /etc/fstab   # /root/swapfile swap swap defaults 0 0
swapon --show
top

Install vnc server

apt -y install tightvncserver xfce4 xfce4-goodies
# answer passwd questions and 'n' to view only
vncserver -kill :1

    create service: /etc/systemd/system/vncserver@.service

    Description=Start TightVNC server at startup
    After=syslog.target network.target

    [Service]
    Type=forking
    User=sqm
    Group=sqm
    WorkingDirectory=/home/sqm

    PIDFile=/home/sqm/.vnc/%H:%i.pid
    ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
    ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
    ExecStop=/usr/bin/vncserver -kill :%i

    [Install]
    WantedBy=multi-user.target

    then enable service

    sudo systemctl daemon-reload
    sudo systemctl enable vncserver@1.service
    sudo systemctl start vncserver@1
    sudo systemctl status vncserver@1

    To set the passwd: vncpasswd
    reboot 

Indi-AllSky
Install indi-allsky

    ​Following indi-allsky

    # as root
    chmod 777 /opt
    # as user
    cd /opt
    git clone https://github.com/aaronwmorris/indi-allsky.git
    cd indi-allsky
    ./misc/build_indi.sh
    ./setup.sh

if you get this error:

The DBUS user session is not defined

Now that the dbus package has been installed...
Please reboot your system and re-run this script to continue

    then:

    cd
    systemctl --user enable indi-allsky.service
    systemctl --user start indi-allsky.service

set apache access password

cd /opt/indi-allsky
source virtualenv/indi-allsky/bin/activate

#New Users
./misc/usertool.py adduser -u sqm

#Change password (set to allskysqm)
./misc/usertool.py resetpass -u sqm

#Set user as administrator
./misc/usertool.py setadmin -u username

To run manually:

cd /opt/indi-allsky
source virtualenv/indi-allsky/bin/activate
./allsky.py run

Mod to set the offset

    See the INDI Config section of the configuration

    {
        "PROPERTIES" : {
            "CCD_CONTROLS" : {
                "Offset" : 10
            }
        },
        "SWITCHES" : {}
    }

Mod to set the temperature

    The temp ramp is set in the INDI Config section of the configuration
    The temp value is set further up in this config

    {
        "PROPERTIES" : {
            "CCD_TEMP_RAMP" : {
                "RAMP_SLOPE"     : 5,
                "RAMP_THRESHOLD" : 0.5
            }
        },
        "SWITCHES" : {}
    }

Mod to set USB bandwidth

{
    "PROPERTIES" : {
        "CCD_CONTROLS" : {
            "BandWidth" : 40
        }
    },
    "SWITCHES" : {}
}

Mod for ZWO ASI120 8->16bit

{
    "PROPERTIES" : {},
    "SWITCHES" : {
        "CCD_VIDEO_FORMAT" : {
            "off"  : ["ASI_IMG_RAW8"],
            "on" : ["ASI_IMG_RAW16"]
        }
    }
}

Config/Image? Label Template:

{timestamp:%Y%m%d %H:%M:%S}
Gain {gain:d}
Temp {temp:0.1f}{temp_unit:s}
Stars {stars:d}\nSQM {sqm:0.0f}

FITS data

    If using, enable and set header info in the Config/Image? tab 

Image Expiration

    Set Config/Image? Image expire/Timelapse expire according to how large your sim is (32gb: 4 days) 

Add extra fields in info box (lower left corner of web pages)

    Create /opt/KOBS/allskyscripts/infoboxupdater
    Add crontab entry to run this every 2 mins and output to /opt/KOBS/allskyscripts/infoboxupdater

    # Every 2 min update info box info
    */2 * * * * /opt/KOBS/allskyscripts/infoboxupdater > /opt/KOBS/allskyscripts/infobox.html

Font sizing:

    ASI294:

    FONT:           FONT_HERSHEY_SIMPLEX
    FONT_HEIGHT:    60
    FONT_X:         10
    FONT_Y:         40
    FONT_COLOR:     200,200,200
    FONT_SCALE:     1.5
    FONT_THICKNESS: 4
    FONT_OUTLINE:   true
    DATE_FORMAT:    %Y%m%d %H:%M:%S

    ASI120:

    FONT:           Sans-Serif
    FONT_HEIGHT:    20
    FONT_X:         5
    FONT_Y:         20
    FONT_COLOR:     230,230,230
    FONT_SCALE:     .5
    FONT_THICKNESS: 2
    FONT_OUTLINE:   true
    DATE_FORMAT:    %Y%m%d %H:%M:%S

File Transfer:

Rebranding:

    Run the rebranding script: /opt/KOBS/allskyscripts/Rebrand 

Create/update the VERSION file

    Run the setVersion script: /opt/KOBS/allskyscripts/setVersion 

Create the addFITShdr script

    Run the addFITShdr script: /opt/KOBS/allskyscripts/addFITShdr
    See /opt/KOBS/allskyscripts/addFITShdr
        this is not working atm, but manually copy/paste into /opt/indi-allsky/indi_allsky/image.py 

Configuration Settings
INDI Configuration Settings
Update indi-allsky

cd /opt/indi-allsky
git pull origin master
   # if issues
   # git fetch --all
   # git reset --hard origin/master
systemctl --user stop indi-allsky
systemctl --user stop gunicorn-indi-allsky.socket
./setup.sh
    #If you get a message about repositories not being valid, you may have to re-enable NTP time sync
    #  sudo timedatectl set-ntp true
    # it might also tell you to reboot and rerun setup.sh
systemctl --user start indi-allsky
    # or better yet, reboot

    Update VERSION file (/opt/KOBS/allskyscripts/setVersion)
    Rebrand (/opt/KOBS/allskyscripts/Rebrand)
    Then apply the mods
        /opt/KOBS/allskyscripts/Rebrand
        /opt/KOBS/allskyscripts/setVersion
        /opt/KOBS/allskyscripts/addFITShdr 

Helper scripts and notes
App's for gps

    App to show diff between system and gps time
    Script to set time every 5 mins 

Env sensor scripts

    envStatus: lists all env data
    ms8607: temp/hum/pres sensor
    htu31d: accurate temp/hum/dp sensor
    skytemp: ir sky temp sensor 

Script to list fits images under /var/www/html/allsky/images/

    fitslist 

Cleanup before release

    /opt/KOBS/envStatus
        remove lux function and print
        remove -l and one line summary print 
    remove /root and /home/sqm .ssh files
    trim /etc/hosts back to only required
    reset network to dhcp for wired connection
        /etc/netplan
            remove 10* and 20*
            move ~save/01* . 
    rename to allskysqm
    change passwords for root, sqm to allskysqm
    change password for admin for web to allskysqm
        htpasswd /etc/indi-allsky/apache.passwd admin 
    change vnc password to allskysqm (vncpasswd)
    reset config for INDI CONFIG
    copy in from /opt/KOBS/sqm: envStatus, startGPSD
    remove dynSysInfo and staticSysInfo 

Misc - just in case needed
Add swap (maybe, doc'd here just in case

    suggested:

    sudo apt-get install dphys-swapfile

    old fashion way:

    swapon --show
    fallocate -l 1G /root/swapfile
    chmod 600 /root/swapfile 
    mkswap /root/swapfile 
    swapon /root/swapfile
    vi /etc/fstab   # /root/swapfile swap swap defaults 0 0
    swapon --show
    top

Mod to set allskysqm data in fits header

    This is now in the /opt/KOBS/allskyscripts/setFITShdr script
    Modified /opt/indi-allsky/indi_allsky/image.py, search for "Override these" 

        # Override these
        ...
            if not v:
                 # skipping empty values
                 continue
 
             hdulist[0].header[k] = v

        ### ADDED by KOBS/Sifan --------------------------
        hdulist[0].header['COMMENT'] = "The following are added from the allsky SQM"
        with open('/opt/KOBS/allskyscripts/allsky.txt') as allskyData:
            for line in allskyData:
                data = line.rstrip().split(":")
                match data[0]:
                    case "Skytemp":
                        hdulist[0].header['SKYTEMP'] = data[1].lstrip()
                    case "Temp":
                        hdulist[0].header['ENVTEMP'] = data[1].lstrip()
                    case "Hum":
                        hdulist[0].header['ENVHUM'] = data[1].lstrip()
                    case "DP":
                        hdulist[0].header['ENVDEW'] = data[1].lstrip()
                    case "Pres":
                        hdulist[0].header['ENVPRES'] = data[1].lstrip()
 
        hdulist[0].header['SQM'] = "" 
        #-------------------------------------------------

        # Add headers from config

Last modified 0 seconds ago
Download in other formats:

    Plain Text 

Trac Powered

Powered by Trac 1.2
By Edgewall Software.

Visit the Kahale Observatory web site
http://jadeseas.net
