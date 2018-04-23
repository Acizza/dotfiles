local awful = require("awful")
local config = require("config")
local gears = require("gears")

WidgetPopup = {}
WidgetPopup.__index = WidgetPopup

function WidgetPopup:new(options)
    local wibar = awful.wibar {
        width = options.width,
        height = options.height,
        opacity = config.panel_opacity,
        visible = false,
        ontop = true,
        type = "popup_menu"
    }

    local widget_popup = {
        wibar = wibar,
        initialized = false,
    }

    setmetatable(widget_popup, WidgetPopup)
    return widget_popup
end

function WidgetPopup:setup(...)
    self.wibar:setup(...)
end

function WidgetPopup:on_open()

end

function WidgetPopup:on_close()

end

function WidgetPopup:toggle()
    if not self.initialized then
        self:initialize()
        self.initialized = true
    end

    self.wibar.visible = not self.wibar.visible

    if self.wibar.visible then
        awful.placement.under_mouse(self.wibar)
        awful.placement.no_offscreen(self.wibar)

        -- Prevent the wibar from moving other open windows out of the way
        self.wibar:struts({
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        })

        self:on_open()
    else
        self:on_close()
    end
end