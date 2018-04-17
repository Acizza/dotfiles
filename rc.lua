math.randomseed(os.time())

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local config = require("config")
local util = require("util")

local run_dialog = require("run_dialog")
local shutdown_menu = require("shutdown_menu")

-- Init the theme now so widgets can access custom theme values
beautiful.init(config.theme_path)

local separator = require("widgets/separator")
local disk_usage = require("widgets/disk_usage")
local ram = require("widgets/ram")
local cpu_usage = require("widgets/cpu_usage")
local volume = require("widgets/volume")

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
                disk_usage.widget,
                separator.middle,
                ram.widget,
                separator.middle,
                cpu_usage.widget,
                separator.middle,
                volume.widget,
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

do
    -- TODO: move somewhere that actually makes sense
    -- Values of type: inc, dec, toggle
    local function adjust_system_volume(type)
        local operation

        if type == "inc" then
            operation = "1%+"
        elseif type == "dec" then
            operation = "1%-"
        elseif type == "toggle" then
            operation = "toggle"
        end

        awesome.spawn("amixer -q sset " .. config.audio_source .. " " .. operation)
    end

    local global_keys = gears.table.join(
        -- Open the shutdown menu
        awful.key({ config.modkey }, "End", shutdown_menu.open),
        -- Shift focus to the right
        awful.key({ config.modkey }, "Right", function() awful.client.focus.byidx(1) end),
        -- Shift focus to left
        awful.key({ config.modkey }, "Left", function() awful.client.focus.byidx(-1) end),
        -- Shift client to the right
        awful.key({ config.modkey, "Shift" }, "Right", function() awful.client.swap.byidx(1) end),
        -- Shift client to the left
        awful.key({ config.modkey, "Shift" }, "Left", function() awful.client.swap.byidx(-1) end),
        -- Increase the number of tag columns
        awful.key({ config.modkey, "Control", "Shift" }, "Right", function() awful.tag.incncol(1, nil, true) end),
        -- Decrease the number of tag columns
        awful.key({ config.modkey, "Control", "Shift" }, "Left", function() awful.tag.incncol(-1, nil, true) end),
        -- Increase master client width factor
        awful.key({ config.modkey, "Control" }, "Right", function() awful.tag.incmwfact(0.05) end),
        -- Decrease master client width factor
        awful.key({ config.modkey, "Control" }, "Left", function() awful.tag.incmwfact(-0.05) end),
        -- Increase client height factor
        awful.key({ config.modkey, "Control" }, "Down", function() awful.client.incwfact(0.05) end),
        -- Decrease client height factor
        awful.key({ config.modkey, "Control" }, "Up", function() awful.client.incwfact(-0.05) end),
        -- Restart Awesome
        awful.key({ config.modkey, "Control", "Shift" }, "r", awesome.restart),
        -- Go to next window layout
        awful.key({ config.modkey }, "space", function() awful.layout.inc(1) end),
        -- Go to previous window layout
        awful.key({ config.modkey, "Shift" }, "space", function() awful.layout.inc(-1) end),
        -- Open run dialog
        awful.key({ config.modkey }, "d", run_dialog.open),
        -- Raise volume
        awful.key({}, "XF86AudioRaiseVolume", function() adjust_system_volume("inc") end),
        -- Lower volume
        awful.key({}, "XF86AudioLowerVolume", function() adjust_system_volume("dec") end),
        -- Toggle volume mute
        awful.key({}, "XF86AudioMute", function() adjust_system_volume("toggle") end)
    )

    for i,shortcut in pairs(config.program_shortcuts) do
        global_keys = gears.table.join(global_keys,
            awful.key(shortcut.modifier, shortcut.key, function()
                awesome.spawn(shortcut.exec)
            end)
        )
    end

    -- Add keys for each tag
    for i = 1, #config.tags do
        global_keys = gears.table.join(global_keys,
            -- View tag
            awful.key({ config.modkey }, "#" .. 9 + i, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]

                if tag then
                    tag:view_only()
                end
            end),
            -- Toggle tag display
            awful.key({ config.modkey, "Control" }, "#" .. 9 + i, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]

                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
            -- Move client to tag
            awful.key({ config.modkey, "Shift" }, "#" .. 9 + i, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]

                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end),
            -- Toggle tag on focused client
            awful.key({ config.modkey, "Control", "Shift" }, "#" .. 9 + i, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]

                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end)
        )
    end

    root.keys(global_keys)

    local client_keys = gears.table.join(
        -- Kill focused process
        awful.key({ config.modkey, "Shift" }, "q", function(c) c:kill() end),
        -- Toggle window fullscreen
        awful.key({ config.modkey }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end),
        -- Toggle floating
        awful.key({ config.modkey, "Control" }, "space",  awful.client.floating.toggle),
        -- Toggle keep on top
        awful.key({ config.modkey }, "t", function(c) c.ontop = not c.ontop end)
    )

    local client_buttons = gears.table.join(
        awful.button({}, 1, function(c)
            client.focus = c
            c:raise()
        end),
        awful.button({ config.modkey }, 1, awful.mouse.client.move),
        awful.button({ config.modkey }, 3, awful.mouse.client.resize)
    )

    awful.rules.rules = {
        { -- Rules for all clients
            rule = { },
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = client_keys,
                buttons = client_buttons,
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
end

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