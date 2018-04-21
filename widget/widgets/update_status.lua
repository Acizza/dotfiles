local update_status = {}

local awful = require("awful")
local config = require("config")
local gears = require("gears")
local lfs = require("lfs")
local naughty = require("naughty")
local wibox = require("wibox")
local widget = require("widget/value_monitor")
local util = require("util")

local string_match = string.match

update_status.startup_delay_secs = 10
update_status.update_time_hours = 2
update_status.update_channel = "nixos-unstable-small"

local MonitorState = {
    OutOfDate = {
        has_newer_date = true,
        text = "unsynced",
    },
    UpToDate = {
        has_newer_date = false,
        text = "synced",
    },
    Checking = {
        has_newer_date = false,
        text = "checking",
    },
    Error = {
        has_newer_date = false,
        text = "error",
    },
}

local run_command = "curl -L https://nixos.org/channels/" .. update_status.update_channel

local value_monitor = ValueMonitor:new {
    label = "SYS",
    format_value = function(data) return data.text end,
    updated_value = function(values, data)
        if data == MonitorState.Error then
            values.value_color = "#ff0000"
        elseif data.has_newer_date then
            values.value_color = "#ffe100"
        end

        return true
    end,
}

-- Update the widget now in case there's a connection problem when initially syncing
value_monitor:set_value(MonitorState.UpToDate)

local function parse_command_output(stdout, stderr, exit_code)
    if exit_code ~= 0 then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error Syncing System Update Channel",
            text = stderr,
        })

        value_monitor:set_value(MonitorState.Error)
        return
    end

    local latest_version = string_match(stdout, "<title>.-release%s(.-)</title>")

    awful.spawn.easy_async("nix-info", function(info_out)
        local current_version = string_match(info_out, "channels%(root%): \"(.-)\"")
        local state

        if latest_version ~= current_version then
            state = MonitorState.OutOfDate
        else
            state = MonitorState.UpToDate
        end

        value_monitor:set_value(state)
    end)
end

function update_status.update()
    value_monitor:set_value(MonitorState.Checking)

    awful.spawn.easy_async(run_command, function(stdout, stderr, _, exit_code)
        parse_command_output(stdout, stderr, exit_code)
    end)
end

if not config.dev_environment then
    -- Create an initial delay to allow an internet connection to be established
    gears.timer {
        timeout = update_status.startup_delay_secs,
        autostart = true,
        single_shot = true,
        callback = function()
            update_status.update()

            gears.timer {
                timeout = update_status.update_time_hours * 3600,
                autostart = true,
                callback = update_status.update,
            }
        end
    }
end

update_status.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    buttons = gears.table.join(
        awful.button({}, 1, update_status.update)
    ),
    value_monitor.textbox,
}

return update_status