math.randomseed(os.time())

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local config = require("config")

-- Init the theme now so widgets can access custom theme values
beautiful.init(config.theme_path)

local key_bindings = require("key_bindings")
local util = require("util")

local run_dialog = require("run_dialog")
local shutdown_menu = require("module/system/shutdown_menu")
local volume_module = require("module/volume")

local separator = require("widgets/separator")
local update_status = require("widgets/update_status")
local disk_usage = require("widgets/disk_usage")
local ram = require("widgets/ram")
local cpu_usage = require("widgets/cpu_usage")
local volume_widget = require("widgets/volume")

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Error during startup",
        text = awesome.startup_errors
    })
end

do
    local in_error = false

    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.crtical,
            title = "Error",
            text = tostring(err)
        })

        in_error = false
    end)
end

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
}

screen.connect_signal("property::geometry", function(screen)
    util.set_wallpaper(screen, config.wallpaper)
end)

do
    local clock = wibox.widget.textclock(config.clock_format, 1)
    local calendar = awful.widget.calendar_popup.month({
        opacity = config.panel_opacity,
        start_sunday = true,
        week_numbers = true,
    })

    calendar:attach(clock, "br")

    local systray = wibox.widget.systray()

    awful.screen.connect_for_each_screen(function(screen)
        util.set_wallpaper(screen, config.wallpaper)
        
        awful.tag(config.tags, screen, awful.layout.layouts[1])

        -- Using these buttons globally on a panel causes an error when a widget
        -- has other buttons attached to it, so we have to attach them manually to each sub-widget
        local scroll_tags_buttons = gears.table.join(
            -- View tag to the right on scroll down
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            -- View tag to the left on scroll up
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
        )

        local taglist_buttons = gears.table.join(
            -- View clicked tag
            awful.button({}, 1, function(t) t:view_only() end),
            -- Toggle tag view
            awful.button({}, 3, awful.tag.viewtoggle),
            scroll_tags_buttons
        )

        screen.taglist = awful.widget.taglist(screen, awful.widget.taglist.filter.all, taglist_buttons)

        screen.layout_box = awful.widget.layoutbox(screen)
        screen.layout_box:buttons(gears.table.join(
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end)
        ))

        screen.bottom_panel = awful.wibar({
            position = "bottom",
            screen = screen,
            opacity = config.panel_opacity,
        })

        screen.bottom_panel:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                screen.taglist,
            },
            { -- Middle widgets
                layout = wibox.layout.fixed.horizontal,
                buttons = scroll_tags_buttons,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                buttons = scroll_tags_buttons,
                separator.left,
                {
                    layout = wibox.layout.fixed.horizontal,
                    buttons = gears.table.join(
                        awful.button({}, 1, update_status.update)
                    ),
                    update_status.widget
                },
                separator.middle,
                disk_usage.widget,
                separator.middle,
                ram.widget,
                separator.middle,
                cpu_usage.widget,
                separator.middle,
                volume_widget.widget,
                separator.middle,
                clock,
                separator.right,
                {
                    widget = wibox.container.margin,
                    top = 5,
                    bottom = 5,
                    left = 15,
                    right = 15,
                    systray,
                },
                screen.layout_box,
            },
        }
    end)
end

root.keys(key_bindings.global)

awful.rules.rules = {
    { -- Rules for all clients
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = key_bindings.client.keys,
            buttons = key_bindings.client.buttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        }
    },
    { -- Floating clients.
        rule_any = gears.table.join(config.floating_windows, {
            role = {
                "pop-up",
            }
        }),
        properties = {
            floating = true
        }
    },
    { -- Assign Steam to its own tag, and remove its border
        rule = {
            instance = "Steam"
        },
        properties = {
            tag = "steam",
            border_width = 0,
        }
    },
    { -- Add titlebars to normal clients and dialogs
        rule_any = {
            type = { "normal", "dialog" }
        },
        except = {
            instance = "Steam"
        },
        properties = {
            titlebars_enabled = true
        },
    },
}

client.connect_signal("manage", function(c)
    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup({
        layout = wibox.layout.align.horizontal,
        { -- Left
            layout = wibox.layout.fixed.horizontal,
            buttons = buttons,
        },
        { -- Middle
            layout = wibox.layout.flex.horizontal,
            { -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
        },
        { -- Right
            layout = wibox.layout.fixed.horizontal()
        },
    })
end)

-- Enable sloppy focus, so that focus follows the mouse
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

if config.dev_environment then
    -- Being in a development environment usually means that we were ran in
    -- something like Xephyr, so we need to start "basic" services like compton ourselves
    awesome.spawn("compton")
else
    for _,program in pairs(config.startup_programs) do
        awesome.spawn(program)
    end
end

collectgarbage()