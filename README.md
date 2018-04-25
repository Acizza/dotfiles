This repository contains my personal [Awesome](https://awesomewm.org/) configuration. Most of it is written from scratch and not really designed to be used by other people.

# Dependencies

If you'd like to try out this configuration, the dependencies required are as follows:

**Lua:**
* `luafilesystem`

**System:**
* `systemd`
* `sp` (used for Spotify info, and can be obtained from [here](https://gist.github.com/wandernauta/6800547))

Note that the systemd requirement can easily be removed, as it is only used for handling system shutdown options in `widgets/system/shutdown_menu.lua`.