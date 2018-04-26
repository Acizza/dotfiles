local util = {}

local lfs = require("lfs")
local gears = require("gears")
local naughty = require("naughty")

local io_open = io.open
local math_random = math.random

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

    return files[math_random(1, #files)]
end

function util.write_file(path, text)
    local file = io_open(path, "w")
    
    if file == nil then
        return false
    end

    local contents = file:write(text)
    file:close()

    return true
end

function util.file_exists(path)
    local file = io_open(path, "r")

    if file ~= nil then
        file:close()
        return true
    else
        return false
    end
end

function util.read_file(path)
    local file = io_open(path, "r")

    if file == nil then
        return nil
    end

    local contents = file:read("*all")
    file:close()

    return contents
end

-- Call with nil to apply the wallpaper to all screens.
function util.set_wallpaper(screen, wallpaper)
    gears.wallpaper.maximized(wallpaper, screen, true)
end

return util