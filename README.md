### what is this?

A hack-around for difficult to diagnose issues between a Synology nas serving samba shares to a Mac.

For some unknown reason no matter how I configure my Mac, I can't keep the disks mounted. I've tried everything on the forums and nothing works. Eventually, it might be a day or two weeks, the samba shares get disconnected. There's no error or notification on my Mac.

So this "project" is an example of a bash script that checks to see if a share, in this case "stuff", is mounted and if it's not it issues a finder command to mount the volume. This results in the share being mounted just like finder would in `/Volumes`. The launchd plist sets this up to run every minute. Tweak it for your needs.

60 seconds might be a bit aggressive for the cron time but that's configurable.  Over the course of a month logs show this script has re-mounted my critical shares four times at an interval of every 6-7 days.
