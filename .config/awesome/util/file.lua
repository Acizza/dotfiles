local file = {}

local lfs = require("lfs")
local naughty = require("naughty")

local io_open = io.open
local math_random = math.random
local string_sub = string.sub

function file.read_dir(dir)
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

function file.get_random_in_dir(dir)
    local files = file.read_dir(dir)

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

function file.write(path, text)
    local file = io_open(path, "w")
    
    if file == nil then
        return false
    end

    local contents = file:write(text)
    file:close()

    return true
end

function file.exists(path)
    local file = io_open(path, "r")

    if file ~= nil then
        file:close()
        return true
    else
        return false
    end
end

function file.read(path)
    local file = io_open(path, "r")

    if file == nil then
        return nil
    end

    local contents = file:read("*all")
    file:close()

    return contents
end

function file.read_and_trim_end(path)
    local contents = file.read(path)
    if contents == nil then return nil end

    return string_sub(contents, 1, #contents - 1)
end

return file