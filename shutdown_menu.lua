local shutdown_menu = {}

local awful = require("awful")
local cairo = require("lgi").cairo
local gears = require("gears")
local wibox = require("wibox")

shutdown_menu.width = 300
shutdown_menu.height = 250

shutdown_menu.options = {}
shutdown_menu.panel = {}

local function menu_item_text(text)
    local key_letter = text:sub(1, 1)
    local other_text = text:sub(2)

    return string.format(
                "<span color=\"#dbdbdb\">%s</span><span color=\"#7a7a7a\">%s</span>",
                key_letter,
                other_text)
end

shutdown_menu.options = {
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

local function initialize()
    local screen = screen.primary
    local size = screen.geometry

    shutdown_menu.panel = awful.wibar({
        ontop = true,
        opacity = 0.8,
        strecth = false,
        width = size.width,
        height = size.height,
        screen = screen,
        -- TODO: adjust to more appropriate type
        type = "dock",
    })

    -- This will allow other windows to be drawn behind the panel
    shutdown_menu.panel:struts({
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    })

    local header_text = wibox.widget {
        markup = "<b>System Options</b>",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
        font = "oxygen 30",
    }

    local option_items = {}

    for i,option in pairs(shutdown_menu.options) do
        table.insert(option_items, wibox.widget {
            markup = option.name,
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
            font = "oxygen 24",
        })
    end

    shutdown_menu.panel:setup({
        layout = wibox.layout.fixed.vertical,
        {
            top = size.height * 0.3,
            bottom = 75,
            layout = wibox.container.margin,
            header_text,
        },
        unpack(option_items)
    })
end

local open = false

function shutdown_menu.open()
    if open then return end
    open = true

    initialize()

    local grabber
    grabber = awful.keygrabber.run(function(mod, key, event)
        if event == "release" then return end

        for i,option in pairs(shutdown_menu.options) do
            if key == option.key then
                awful.keygrabber.stop(grabber)
                shutdown_menu.close()

                option.func()
                break
            end
        end
    end)
end

function shutdown_menu.close()
    if not open then return end

    shutdown_menu.panel:remove()
    open = false
end

return shutdown_menu