local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")

local systray = wibox.widget.systray()
systray:set_base_size(36)
systray.set_horizontal(false)

local scroll_offset = 0
local scroll_step = 40
local container_width = 100
local container_height = 100

local systray_margin = wibox.widget({
	systray,
	left = 0,
	widget = wibox.container.margin,
})

local app_tray_widget = wibox.widget({
	systray_margin,
	strategy = "exact",
	width = container_width,
	height = 150,
	widget = wibox.container.constraint,
})

local function clamp_scroll()
	local content_w = select(1, systray:fit({ dpi = 96 }, 9999, 150)) or 0
	local max_scroll = math.max(0, content_w - container_width)
	if scroll_offset > 0 then
		scroll_offset = 0
	elseif scroll_offset < -max_scroll then
		scroll_offset = -max_scroll
	end
	systray_margin.left = -scroll_offset
end

app_tray_widget:buttons(gears.table.join(
	awful.button({}, 4, function()
		scroll_offset = scroll_offset + scroll_step
		clamp_scroll()
	end),
	awful.button({}, 5, function()
		scroll_offset = scroll_offset - scroll_step
		clamp_scroll()
	end)
))

return app_tray_widget
