local run_dialog = {}

local awful = require("awful")
local wibox = require("wibox")
local config = require("config")

run_dialog.width = screen.primary.geometry.width * 0.6

function run_dialog.open()
    local dialog_container = awful.wibar {
        position = "top",
        stretch = false,
        ontop = true,
        opacity = config.panel_opacity,
        x = screen.primary.geometry.width - run_dialog.width / 2,
        width = run_dialog.width,
    }

    local prompt_textbox = wibox.widget.textbox()

    dialog_container:setup({
        layout = wibox.layout.align.horizontal,
        {
            widget = wibox.container.margin,
            left = 10,
            prompt_textbox,
        },
    })

    awful.prompt.run({
        prompt = "<b>run: </b>",
        textbox = prompt_textbox,
        exe_callback = function(input)
            dialog_container:remove()
            
            if input and #input > 0 then
                awesome.spawn(input)
            end
        end,
        hooks = {
            {{}, "Escape", function(_) dialog_container:remove() end},
        }
    })
end

return run_dialog