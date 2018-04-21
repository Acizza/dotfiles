local key_bindings = {}

local awful = require("awful")
local config = require("config")
local gears = require("gears")

local run_dialog = require("run_dialog")
local shutdown_menu = require("module/system/shutdown_menu")
local volume_module = require("module/volume")

key_bindings.global = gears.table.join(
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
    awful.key({}, "XF86AudioRaiseVolume", volume_module.increment_source),
    -- Lower volume
    awful.key({}, "XF86AudioLowerVolume", volume_module.decrement_source),
    -- Toggle volume mute
    awful.key({}, "XF86AudioMute", volume_module.toggle_source_mute)
)

-- Add key_bindings for each tag
for i = 1, #config.tags do
    key_bindings.global = gears.table.join(key_bindings.global,
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

for i,shortcut in pairs(config.program_shortcuts) do
    key_bindings.global = gears.table.join(key_bindings.global,
        awful.key(shortcut.modifier, shortcut.key, function()
            awesome.spawn(shortcut.exec)
        end)
    )
end

key_bindings.client = {
    keys = gears.table.join(
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
    ),
    buttons = gears.table.join(
        -- Focus window
        awful.button({}, 1, function(c)
            client.focus = c
            c:raise()
        end),
        -- Move window
        awful.button({ config.modkey }, 1, awful.mouse.client.move),
        -- Resize window
        awful.button({ config.modkey }, 3, awful.mouse.client.resize)
    )
}

return key_bindings