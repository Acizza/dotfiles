local spotify = {}

local awful = require("awful")
local key_bindings = require("key_bindings")

function spotify.prev_track()
    awesome.spawn("sp prev")
end

function spotify.toggle_track()
    awesome.spawn("sp play")
end

function spotify.next_track()
    awesome.spawn("sp next")
end

key_bindings.add_global_keys(
    -- Play previous track
    awful.key({}, "XF86AudioPrev", spotify.prev_track),
    -- Play / pause track
    awful.key({}, "XF86AudioPause", spotify.toggle_track),
    awful.key({}, "XF86AudioPlay", spotify.toggle_track),
    -- Play next track
    awful.key({}, "XF86AudioNext", spotify.next_track)
)

return spotify