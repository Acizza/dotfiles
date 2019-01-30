local shutdown_menu = {}

local awful = require("awful")
local wibox = require("wibox")
local popup = require("widgets/popup")

local function menu_item_text(text)
    local key_letter = text:sub(1, 1)
    local other_text = text:sub(2)

    return string.format(
                "<span color=\"#dbdbdb\">%s</span><span color=\"#7a7a7a\">%s</span>",
                key_letter,
                other_text)
end

local screen_size = screen.primary.geometry

local shutdown_menu = WidgetPopup:new {
    width = screen_size.width,
    height = screen_size.height,
    is_panel_widget = false,
}

function shutdown_menu:initialize()
    self.options = {
        {
            name = menu_item_text("Logout"),
            key = "l",
            func = function() awesome.quit() end
        },
        {
            name = menu_item_text("Reboot"),
            key = "r",
            func = function() awesome.spawn("systemctl reboot") end
        },
        {
            name = menu_item_text("Shutdown"),
            key = "s",
            func = function() awesome.spawn("systemctl poweroff") end
        },
        {
            name = menu_item_text("Exit"),
            key = "e",
            func = function() end
        },
    }

    local header_text = wibox.widget {
        markup = "<b>System Options</b>",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
        font = "oxygen 30",
    }

    local option_items = {}

    for i,option in pairs(self.options) do
        option_items[#option_items + 1] = wibox.widget {
            markup = option.name,
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
            font = "oxygen 24",
        }
    end

    local items_widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        header_text,
        {
            layout = wibox.container.margin,
            top = 15,
        },
        unpack(option_items)
    }

    self:setup({
        layout = wibox.container.place,
        items_widget,
    })
end

function shutdown_menu:on_open()
    local grabber

    grabber = awful.keygrabber.run(function(mod, key, event)
        if event == "release" then return end

        for i,option in pairs(self.options) do
            if key == option.key then
                awful.keygrabber.stop(grabber)
                self:close()

                option.func()
                break
            end
        end
    end)
end

return shutdown_menu