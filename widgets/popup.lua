local popup = {}

local awful = require("awful")
local config = require("config")
local gears = require("gears")

popup.open_popup = nil

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
        is_panel_widget = options.is_panel_widget == nil
            and true or options.is_panel_widget,
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

function WidgetPopup:open()
    if self.wibar.visible then return end

    if popup.open_popup ~= nil then
        popup.open_popup:close()
    end

    popup.open_popup = self
    
    if not self.initialized then
        self:initialize()
        self.initialized = true
    end

    self.wibar.visible = true

    if self.is_panel_widget then
        awful.placement.under_mouse(self.wibar)
        awful.placement.no_offscreen(self.wibar)
    end

    -- Prevent the wibar from moving other open windows out of the way
    self.wibar:struts({
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    })

    self:on_open()
end

function WidgetPopup:close()
    if not self.wibar.visible then return end

    self.wibar.visible = false
    self:on_close()

    popup.open_popup = nil
end

function WidgetPopup:toggle()
    if self.wibar.visible then
        self:close()
    else
        self:open()
    end
end

return popup