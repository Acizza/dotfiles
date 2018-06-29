local weather = {}

local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local gears = require("gears")
local wibox = require("wibox")

require("widgets/value_monitor")

local string_format = string.format
local string_match = string.match

local widget_config = config.widgets.weather

local request_str = string_format(
    "api.openweathermap.org/data/2.5/weather?id=%s&APPID=%s&units=imperial",
    widget_config.city_id,
    widget_config.api_key
)

local WeatherState = {
    WithInfo = {},
    NoInfo = {},
    Error = {},
}

local value_monitor = ValueMonitor:new {
    label = "WX"
}

function value_monitor:on_set(data)
    if data.state == WeatherState.WithInfo then
        return {
            formatted = string_format("%s %s°F", data.info.condition_str, data.info.temp)
        }
    elseif data.state == WeatherState.NoInfo then
        return {
            formatted = "no data"
        }
    elseif data.state == WeatherState.Error then
        return {
            formatted = "error",
            value_color = beautiful.critical_color,
        }
    end
end

value_monitor:set_value({
    state = WeatherState.NoInfo
})

weather.widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    value_monitor.textbox,
}

function weather.update()
    awful.spawn.easy_async("curl " .. request_str, function(stdout, _, _, error_code)
        if error_code ~= 0 then
            value_monitor:set_value({
                state = WeatherState.Error,
            })

            -- TODO: show notification
            print(stdout)
            return
        end

        local info = {
            condition_str = string_match(stdout, "\"main\":\"(%a+)\""),
            temp = string_match(stdout, "\"temp\":(%d+)"),
        }

        value_monitor:set_value({
            state = WeatherState.WithInfo,
            info = info
        })
    end)
end

if not config.dev_environment then
    gears.timer {
        timeout = widget_config.startup_delay_secs,
        autostart = true,
        single_shot = true,
        callback = function()
            weather.update()

            gears.timer {
                timeout = widget_config.update_time_secs,
                autostart = true,
                callback = weather.update,
            }
        end
    }
end

return weather