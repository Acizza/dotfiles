local separator = {}

local config = require("config")
local wibox = require("wibox")

local widget_config = config.widgets.separator

separator.left = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = widget_config.left_text,
        font = "10",
    }
}

separator.middle = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = widget_config.middle_text,
        font = "10",
    },
}

separator.right = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = widget_config.right_text,
        font = "10",
    },
}

return separator