local system_status = {}

local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local gears = require("gears")
local lfs = require("lfs")
local naughty = require("naughty")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")
local util = require("util")

local popup = require("widgets/panel/system_status/popup")

local string_match = string.match

local widget_config = config.widgets.system_status

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

-- Automatically fetch the update channel
awful.spawn.easy_async("nix-channel --list", function(stdout)
    local channel = string_match(stdout, "nixos (.-)\n")
    system_status.update_command = "curl -L " .. channel
end)

local value_monitor = ValueMonitor:new {
    label = "SYS",
    format_value = function(data) return data.text end,
    updated_value = function(values, data)
        if data == MonitorState.Error then
            values.value_color = beautiful.critical_color
        elseif data.has_newer_date then
            values.value_color = beautiful.warning_color
        end

        return true
    end,
}

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

function system_status.update()
    value_monitor:set_value(MonitorState.Checking)

    awful.spawn.easy_async(system_status.update_command, function(stdout, stderr, _, exit_code)
        parse_command_output(stdout, stderr, exit_code)
    end)
end

system_status.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    buttons = gears.table.join(
        awful.button({}, 1, function() popup:toggle() end),
        awful.button({}, 3, system_status.update)
    ),
    value_monitor.textbox,
}

if not config.dev_environment then
    -- Create an initial delay to allow an internet connection to be established
    gears.timer {
        timeout = widget_config.startup_delay_secs,
        autostart = true,
        single_shot = true,
        callback = function()
            system_status.update()

            gears.timer {
                timeout = widget_config.update_time_hours * 3600,
                autostart = true,
                callback = system_status.update,
            }
        end
    }
end

return system_status