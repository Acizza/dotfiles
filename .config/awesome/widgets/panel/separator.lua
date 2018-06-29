local separator = {}

local config = require("config")
local wibox = require("wibox")

local widget_config = config.widgets.separator

separator.left = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = widget_config.left_text,
    }
}

separator.middle = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = widget_config.middle_text,
    },
}

separator.right = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = widget_config.right_text,
    },
}

return separator