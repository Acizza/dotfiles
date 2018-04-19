local volume = {}

local awful = require("awful")
local config = require("config")
local volume_widget = require("widgets/volume")

local table_pack = table.pack
local string_match = string.match

local function set_volume(operation)
    local command = "amixer -q sset " .. config.audio_source .. " " .. operation

    awful.spawn.easy_async(command, function()
        volume_widget.update()
    end)
end

function volume.increment_source()
    set_volume("1%+")
end

function volume.decrement_source()
    set_volume("1%-")
end

function volume.toggle_source_mute()
    set_volume("toggle")
end

return volume