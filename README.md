This respository contains my personal user config files for Arch Linux. It also contains my custom desktop environment that can be used with the Awesome window manager.

To use the configuration with Awesome, the following dependencies are required:
* `luafilesystem`
* `systemd`
* `sp` (used for Spotify info, and can be obtained from [here](https://gist.github.com/wandernauta/6800547))

Note that the systemd requirement can easily be removed, as it is only used for handling system shutdown options in `.config/awesome/widgets/system/shutdown_menu.lua`.