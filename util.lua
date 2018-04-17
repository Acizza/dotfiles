local util = {}

local lfs = require("lfs")
local gears = require("gears")

function util.read_dir(dir)
    local files = {}
    
    for file in lfs.dir(dir) do
        if file ~= "." and file ~= ".." then
            local path = dir .. '/' .. file
            local attr = lfs.attributes(path)

            if attr.mode ~= "directory" then
                files[#files + 1] = path
            end
        end
    end

    return files
end

function util.random_file_in_dir(dir)
    local files = util.read_dir(dir)

    if #files == 0 then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Empty Directory",
            text = "no files found in " .. dir
        })

        return
    end

    return files[math.random(1, #files)]
end

-- Call with nil to apply the wallpaper to all screens.
function util.set_wallpaper(screen, wallpaper)
    gears.wallpaper.maximized(wallpaper, screen, true)
end

return util