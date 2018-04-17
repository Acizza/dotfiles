local separator = {}

local wibox = require("wibox")

separator.left_text = "[ "
separator.middle_text = " ][ "
separator.right_text = " ]"

separator.left = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = separator.left_text,
        font = "10",
    }
}

separator.middle = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = separator.middle_text,
        font = "10",
    },
}

separator.right = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.widget.textbox,
        text = separator.right_text,
        font = "10",
    },
}

return separator