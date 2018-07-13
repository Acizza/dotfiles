local system = {}

local config = require("config")
local gears = require("gears")

-- Call with screen set to nil to apply the wallpaper to all screens.
function system.set_wallpaper(screen, wallpaper)
    if wallpaper == nil then return end

    gears.wallpaper.maximized(wallpaper, screen, true)

    if not config.dev_environment then
        awesome.spawn("wal -q -i \"" .. wallpaper .. "\"")
    end
end

return system