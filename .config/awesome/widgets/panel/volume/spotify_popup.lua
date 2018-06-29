local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local gears = require("gears")
local lfs = require("lfs")
local spotify_module = require("module/spotify")
local file = require("util/file")
local wibox = require("wibox")

local string_format = string.format
local string_match = string.match

local dpi = require("beautiful.xresources").apply_dpi

local spotify_popup = WidgetPopup:new {
    width = 325,
    height = 128,
}

local widget_config = config.widgets.volume

local prev_song_text = "<"
local toggle_song_text = "="
local play_song_text = "=>"
local next_song_text = ">"

function spotify_popup:initialize_media_button(text, spotify_func)
    local click_func = function()
        spotify_func()

        -- Delay the widget update to give Spotify time to update the metadata
        gears.timer {
            timeout = 1,
            autostart = true,
            single_shot = true,
            callback = function() self:update() end,
        }
    end

    return wibox.widget {
        text = text,
        font = "14",
        align = "center",
        buttons = gears.table.join(
            awful.button({}, 1, click_func)
        ),
        widget = wibox.widget.textbox(),
    }
end

function spotify_popup:initialize_song_info_text(title, value_widget)
    return {
        layout = wibox.layout.fixed.horizontal,
        {
            markup = "<span color=\"" .. beautiful.widget_label .. "\">" .. title .. "</span> ",
            widget = wibox.widget.textbox(),
        },
        {
            layout = wibox.container.scroll.horizontal,
            step_function = wibox.container.scroll.step_functions
                                .waiting_nonlinear_back_and_forth,
            speed = 100,
            value_widget,
        }
    }
end

function spotify_popup:initialize_paths()
    self.album_cover_cache = gears.filesystem.get_cache_dir() .. "spotify/"
    lfs.mkdir(self.album_cover_cache)
end

function spotify_popup:initialize()
    self:initialize_paths()

    self.update_timer = gears.timer {
        timeout = widget_config.spotify_update_time_secs,
        autostart = false,
        callback = function() self:update() end,
    }

    self.album_art = wibox.widget.imagebox(nil, true)

    self.song_title = wibox.widget.textbox()
    self.song_artist = wibox.widget.textbox()
    self.song_album = wibox.widget.textbox()

    self.prev_song = self:initialize_media_button(prev_song_text, spotify_module.prev_track)
    self.toggle_song = self:initialize_media_button(toggle_song_text, spotify_module.toggle_track)
    self.next_song = self:initialize_media_button(next_song_text, spotify_module.next_track)

    self:set_nothing_playing()

    self:setup({
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.manual,
            forced_width = dpi(128),
            forced_height = dpi(98),
            self.album_art,
        },
        {
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.margin,
                top = dpi(10),
                bottom = dpi(15),
                {
                    markup = "<b>Spotify Info</b>",
                    align = "center",
                    widget = wibox.widget.textbox(),
                },
            },
            {
                layout = wibox.container.margin,
                left = dpi(15),
                right = dpi(5),
                bottom = dpi(18),
                {
                    layout = wibox.layout.fixed.vertical,
                    self:initialize_song_info_text("Title", self.song_title),
                    self:initialize_song_info_text("Artist", self.song_artist),
                    self:initialize_song_info_text("Album", self.song_album),
                },
            },
            {
                layout = wibox.layout.flex.horizontal,
                self.prev_song,
                self.toggle_song,
                self.next_song,
            }
        }
    })
end

function spotify_popup:set_nothing_playing()
    self.song_title.text = "none"
    self.song_artist.text = "none"
    self.song_album.text = "none"

    self.album_art.image = nil
end

local function parse_image_id(url)
    return string_match(url, "image/(.+)")
end

function spotify_popup:update_album_cover(url)
    if url == "" then return end

    local cached_image_path = self.album_cover_cache .. parse_image_id(url)

    if file.exists(cached_image_path) then
        self.album_art.image = cached_image_path
        return
    end

    local run_command = string_format("curl -L -o \"%s\" %s", cached_image_path, url)

    awful.spawn.easy_async(run_command, function()
        self.album_art.image = cached_image_path
    end)
end

function spotify_popup:update()
    spotify_module.get_metadata(function(metadata)
        if metadata == nil then
            self:set_nothing_playing()
            return
        end

        self.song_title.text = metadata.title
        self.song_artist.text = metadata.artist
        self.song_album.text = metadata.album

        self:update_album_cover(metadata.cover_url)
    end)
end

function spotify_popup:on_open()
    self:update()
    self.update_timer:again()
end

function spotify_popup:on_close()
    self.update_timer:stop()
end

return spotify_popup