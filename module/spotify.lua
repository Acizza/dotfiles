local spotify = {}

local awful = require("awful")
local key_bindings = require("key_bindings")

local string_match = string.match

function spotify.get_metadata(callback)
    awful.spawn.easy_async("sp metadata", function(stdout, _, _, error_code)
        if error_code ~= 0 then
            callback(nil)
            return
        end

        local metadata = {
            title = string_match(stdout, "title|(.-)\n"),
            artist = string_match(stdout, "artist|(.-)\n"),
            album = string_match(stdout, "album|(.-)\n"),
            cover_url = string_match(stdout, "artUrl|(.-)\n"),
        }

        callback(metadata)
    end)
end

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