local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local M = {}

local COL_ICON_BG = "#f9e2af"
local COL_SLIDER_BG = "#1e1e2e"
local COL_BRIGHT = "#b4befe"
local COL_TEXT = "#1e1e2e"
local COL_TEXT_ALT = "#cdd6f4"

local ICON_W = 90
local SLIDER_W = 500
local ROW_H = 150

local icon_textbox = wibox.widget({
	text = "󰃠",
	align = "center",
	valign = "center",
	font = "BigBlueTermPlus Nerd Font Propo 20",
	widget = wibox.widget.textbox,
})

local value_label = wibox.widget({
	text = "0%",
	align = "center",
	valign = "center",
	font = "BigBlueTermPlus Nerd Font Propo 11",
	widget = wibox.widget.textbox,
})

local icon_col = wibox.widget({
	{
		{
			icon_textbox,
			value_label,
			spacing = 4,
			layout = wibox.layout.fixed.vertical,
		},
		halign = "center",
		valign = "center",
		widget = wibox.container.place,
	},
	strategy = "exact",
	width = ICON_W,
	height = ROW_H,
	widget = wibox.container.constraint,
})
icon_col = wibox.widget({
	icon_col,
	fg = COL_TEXT_ALT,
	widget = wibox.container.background,
})

local slider = wibox.widget({
	--[[ 	bar_shape = gears.shape.rounded_bar, ]]
	bar_height = 10,
	bar_color = "#313244",
	bar_active_color = COL_BRIGHT,
	handle_color = COL_BRIGHT,
	--[[ 	handle_shape = gears.shape.circle, ]]
	handle_border_color = COL_TEXT,
	handle_border_width = 1,
	handle_width = 20,
	value = 0,
	minimum = 0,
	maximum = 100,
	widget = wibox.widget.slider,
})

local slider_col = wibox.widget({
	{
		slider,
		left = 16,
		right = 16,
		widget = wibox.container.margin,
	},
	halign = "center",
	valign = "center",
	widget = wibox.container.place,
})
slider_col = wibox.widget({
	{
		slider_col,
		strategy = "exact",
		width = SLIDER_W,
		height = ROW_H,
		widget = wibox.container.constraint,
	},
	bg = COL_SLIDER_BG,
	fg = COL_TEXT_ALT,
	widget = wibox.container.background,
})

M.widget = wibox.widget({
	icon_col,
	slider_col,
	layout = wibox.layout.fixed.horizontal,
})

local function update_ui(pct)
	value_label.text = pct .. "%"
	slider:set_value(pct)
end

local function refresh()
	awful.spawn.easy_async_with_shell("brightnessctl -m | awk -F, '{print $4}' | tr -d '%'", function(stdout)
		local pct = tonumber(stdout:match("%d+")) or 0
		update_ui(pct)
	end)
end

slider:connect_signal("property::value", function(s)
	local v = math.floor(s:get_value())
	awful.spawn.with_shell("brightnessctl set " .. v .. "%")
	value_label.text = v .. "%"
end)

M.refresh = refresh
M.slider = slider

refresh()

gears.timer({
	timeout = 2,
	autostart = true,
	call_now = false,
	callback = refresh,
})

return M
