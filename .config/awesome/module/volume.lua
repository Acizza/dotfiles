local volume = {}

local awful = require("awful")
local config = require("config")
local gears = require("gears")
local key_bindings = require("key_bindings")

local table_pack = table.pack
local string_match = string.match

local on_set_hooks = {}

function volume.add_set_hook(func)
    on_set_hooks[#on_set_hooks + 1] = func
end

local function set_volume(operation)
    local command = "amixer -q sset " .. config.audio_source .. " " .. operation

    awful.spawn.easy_async(command, function()
        for _,func in pairs(on_set_hooks) do
            func()
        end
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

key_bindings.add_global_keys(
    -- Raise volume
    awful.key({}, "XF86AudioRaiseVolume", volume.increment_source),
    -- Lower volume
    awful.key({}, "XF86AudioLowerVolume", volume.decrement_source),
    -- Toggle volume mute
    awful.key({}, "XF86AudioMute", volume.toggle_source_mute)
)

return volume