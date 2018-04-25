local awful = require("awful")
local gears = require("gears")
local lfs = require("lfs")
local wibox = require("wibox")
local util = require("util")

local string_format = string.format
local string_match = string.match

local spotify_popup = WidgetPopup:new {
    width = 650,
    height = 256,
}

function spotify_popup:initialize_paths()
    self.album_cover_cache = gears.filesystem.get_cache_dir() .. "spotify/"
    lfs.mkdir(self.album_cover_cache)
end

function spotify_popup:initialize()
    self:initialize_paths()

    self.album_art = wibox.widget.imagebox(nil, true)

    self.song_title = ValueMonitor:new {
        label = "Title",
    }

    self.song_artist = ValueMonitor:new {
        label = "Artist",
    }

    self.song_album = ValueMonitor:new {
        label = "Album",
    }

    self:set_nothing_playing()

    self:setup({
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.manual,
            forced_width = 256,
            forced_height = 196,
            self.album_art,
        },
        {
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.margin,
                top = 20,
                bottom = 30,
                {
                    markup = "<b>Spotify Info</b>",
                    align = "center",
                    widget = wibox.widget.textbox(),
                },
            },
            {
                layout = wibox.container.margin,
                left = 30,
                right = 10,
                {
                    layout = wibox.layout.fixed.vertical,
                    self.song_title.textbox,
                    self.song_artist.textbox,
                    self.song_album.textbox,
                },
            }
        }
    })
end

function spotify_popup:set_nothing_playing()
    self.song_title:set_value("none")
    self.song_artist:set_value("none")
    self.song_album:set_value("none")

    self.album_art.image = nil
end

local function parse_image_id(url)
    return string_match(url, "image/(.+)")
end

function spotify_popup:update_album_cover(url)
    if url == "" then return end

    local cached_image_path = self.album_cover_cache .. parse_image_id(url)

    if util.file_exists(cached_image_path) then
        self.album_art.image = cached_image_path
        return
    end

    local run_command = string_format("curl -L -o \"%s\" %s", cached_image_path, url)

    awful.spawn.easy_async(run_command, function()
        self.album_art.image = cached_image_path
    end)
end

function spotify_popup:on_open()
    awful.spawn.easy_async("sp metadata", function(stdout, _, _, exit_code)
        if exit_code ~= 0 then
            self:set_nothing_playing()
            return
        end

        self.song_title:set_value(string_match(stdout, "title|(.-)\n"))
        self.song_artist:set_value(string_match(stdout, "artist|(.-)\n"))
        self.song_album:set_value(string_match(stdout, "album|(.-)\n"))

        spotify_popup:update_album_cover(string_match(stdout, "artUrl|(.-)\n"))
    end)
end

return spotify_popup