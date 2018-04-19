local update_status = {}

local awful = require("awful")
local config = require("config")
local gears = require("gears")
local lfs = require("lfs")
local naughty = require("naughty")
local wibox = require("wibox")
local widget = require("widgets/widget")
local util = require("util")

local string_match = string.match

update_status.startup_delay_secs = 10
update_status.update_time_hours = 2
update_status.update_channel = "nixos-unstable-small"

update_status.up_to_date_text = "synced"
update_status.out_of_date_text = "unsynced"

local run_command = "curl -L https://nixos.org/channels/" .. update_status.update_channel

local value_monitor = ValueMonitor:new {
    label = "SYS",
    format_value = function(data) return data.text end,
    updated_value = function(values, data)
        if data.has_newer_date then
            values.value_color = "#ffe100"
        end

        return true
    end,
}

update_status.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    value_monitor.textbox,
}

local function update_monitor(is_out_of_date)
    local text = is_out_of_date and
        update_status.out_of_date_text or
        update_status.up_to_date_text

    local data = {
        has_newer_date = is_out_of_date,
        text = text,
    }

    value_monitor:set_value(data)
end

-- Update the widget now in case there's a connection problem when initially syncing
update_monitor(false)

local function parse_command_output(stdout, stderr, exit_code)
    if exit_code ~= 0 then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error Syncing System Update Channel",
            text = stderr,
        })

        return
    end

    local latest_version = string_match(stdout, "<title>.-release%s(.-)</title>")

    awful.spawn.easy_async("nix-info", function(info_out)
        local current_version = string_match(info_out, "channels%(root%): \"(.-)\"")
        update_monitor(latest_version ~= current_version)
    end)
end

if not config.dev_environment then
    -- Create an initial delay to allow an internet connection to be established
    gears.timer {
        timeout = update_status.startup_delay_secs,
        autostart = true,
        single_shot = true,
        callback = function()
            awful.widget.watch(
                run_command,
                update_status.update_time_hours * 3600,
                function(_, stdout, stderr, _, exit_code)
                    parse_command_output(stdout, stderr, exit_code)
                end
            )
        end
    }
end

return update_status