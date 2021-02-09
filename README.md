# Mod's Arch Install Script
<p>This is a work in progress and currently does not work!</p>

<p>An install script for Arch Linux <br>
Allows for Automatic or Manual Partitioning and Declaring Variables such as Hostname, Timezone, and Username to be used. <br>
There are better scripts out there (IE. AUI), this is only a personal script to setup an arch install how I like it.
</p>

## Requirements:
### System:
- EFI Compatible
- 64-bit Architecture 
This is due to how the script is currently written (Installing Grub for efix86_64)


## Using The Script
<p>On boot of your image run the following commands in order:</p>

- `pacman -Syu`
- `pacman -S git`
- `git clone git://github.com/Modernespiel/mods-arch-install`
- `cd mods-arch-install`
- `./install.sh`

<p>After that follow the on-screen prompts and the script will do the rest.</p>
