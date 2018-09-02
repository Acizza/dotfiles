local system_status = {}

local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")
local widget = require("widgets/value_monitor")

local popup = require("widgets/panel/system_status/popup")

local string_match = string.match
local string_sub = string.sub

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
    local channel = string_match(stdout, "nixos (.-)\n") .. "/git-revision"
    system_status.fetch_remote_revision_cmd = "curl -L " .. channel
end)

local value_monitor = ValueMonitor:new {
    label = "SYS"
}

function value_monitor:on_set(data)
    local values = {
        formatted = data.text
    }

    if data == MonitorState.Error then
        values.value_color = beautiful.critical_color
    elseif data.has_newer_date then
        values.value_color = beautiful.warning_color
    end

    return values
end

value_monitor:set_value(MonitorState.UpToDate)

local function update_from_revision(remote_revision)
    awful.spawn.easy_async("nixos-version --revision", function(local_revision, stderr, _, exit_code)
        if exit_code ~= 0 then
            value_monitor:set_value(MonitorState.Error)
            system_status.display_error("error fetching local version: " .. tostring(stderr))
            return
        end

        -- Trim newline from output
        local_revision = string_sub(local_revision, 1, #local_revision - 1)

        -- Check if the remote revision starts with the same hash as the local one
        if string_sub(remote_revision, 1, #local_revision) == local_revision then
            value_monitor:set_value(MonitorState.UpToDate)
        else
            value_monitor:set_value(MonitorState.OutOfDate)
        end
    end)
end

function system_status.update()
    value_monitor:set_value(MonitorState.Checking)

    awful.spawn.easy_async(system_status.fetch_remote_revision_cmd, function(rev, stderr, _, exit_code)
        if exit_code ~= 0 then
            value_monitor:set_value(MonitorState.Error)
            system_status.display_error("error fetching latest remote version: " .. tostring(stderr))
            return
        end

        update_from_revision(rev)
    end)
end

function system_status.display_error(msg)
    value_monitor:set_value(MonitorState.Error)

    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Error In System Status Widget",
        text = msg,
    })
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