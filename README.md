# JYubuntu-creator
The shell script that busts out an ISO of JYubuntu: THE semi-official Linux distro of Dollsbook (https://dollsbook.com)

Let me level with ya. I am a fan of the Ubuntu respinners like Linux Respin, Pinguy Builder, Bodhibuilder etc. (all Remastersys forks), but it wasn't enough for me. 

I went on Google and found on the [Ubuntu Help Wiki on how it's basically done](https://help.ubuntu.com/community/MakeALiveCD/DVD/BootableFlashFromHarddiskInstall).

I went and made a shell script out of it to basically automate it.

Requirements:

+ Installed Ubuntu, Debian or any of its zillions of derivatives
+ Root or sudo access (cuz you'll need it. The script requires it)
+ Patience. 
+ [Whataburger](http://whataburger.com) or your favorite beverage, food, or other vice.

If you require some fine-tuned customization, then [Linux Respin](https://github.com/ch1x0r/LinuxRespin), [Bodhibuilder](https://github.com/stacefauske/bodhibuilder), [Pinguy Builder](https://github.com/pinguy/Pinguy-Builder) or [Cubic](https://launchpad.net/~cubic-wizard/+archive/ubuntu/release) might be better for you. This script is automatic, asks no questions and all customizations must be made **before** the script is run.

***This script is a WIP (work-in-progress), including this README.MD. This script requires some advanced knowledge of editing by hand certain files in your installation (as admin/root), and the like. I can offer some advice, but I won't be holding your hand for you.***

# Known issues

+ Do *not* delete the `work` or `cd` directories right after running this script! You must reboot before doing so. Otherwise, it will kill systemd and rebooting and shutting down will be through your power button instead.

Otherwise, please test this script, and offering your own suggestions will be welcomed! 

73, KI5JYD QTH: EM12gr
