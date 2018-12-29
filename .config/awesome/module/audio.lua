local audio = {}

local awful = require("awful")
local config = require("config")
local gears = require("gears")
local key_bindings = require("key_bindings")

local table_pack = table.pack
local string_match = string.match

local on_volume_set_hooks = {}

function audio.add_volume_set_hook(func)
    on_volume_set_hooks[#on_volume_set_hooks + 1] = func
end

local function set_volume(operation)
    local command = "amixer -q sset " .. config.audio_source .. " " .. operation

    awful.spawn.easy_async(command, function()
        for _,func in pairs(on_volume_set_hooks) do
            func()
        end
    end)
end

function audio.increment_volume()
    set_volume("1%+")
end

function audio.decrement_volume()
    set_volume("1%-")
end

function audio.toggle_volume_mute()
    set_volume("toggle")
end

function audio.prev_music_track()
    awesome.spawn("lollypop -p")
end

function audio.toggle_music_track()
    awesome.spawn("lollypop -t")
end

function audio.next_music_track()
    awesome.spawn("lollypop -n")
end

key_bindings.add_global_keys(
    -- Raise volume
    awful.key({}, "XF86AudioRaiseVolume", audio.increment_volume),
    -- Lower volume
    awful.key({}, "XF86AudioLowerVolume", audio.decrement_volume),
    -- Toggle volume mute
    awful.key({}, "XF86AudioMute", audio.toggle_volume_mute),
    -- Play previous music track
    awful.key({}, "XF86AudioPrev", audio.prev_music_track),
    -- Play / pause music track
    awful.key({}, "XF86AudioPause", audio.toggle_music_track),
    awful.key({}, "XF86AudioPlay", audio.toggle_music_track),
    -- Play next music track
    awful.key({}, "XF86AudioNext", audio.next_music_track)
)

return audio