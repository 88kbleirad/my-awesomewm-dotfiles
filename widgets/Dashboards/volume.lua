local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local M = {}
local COL_SLIDER_BG = "#1e1e2e"
local COL_VOLUME = "#89b4fa"
local COL_TEXT = "#1e1e2e"
local COL_TEXT_ALT = "#cdd6f4"
local ICON_W = 90
local SLIDER_W = 500
local ROW_H = 150
local function volume_icon(vol, muted)
	if muted or vol == 0 then
		return "󰝟"
	elseif vol < 34 then
		return "󰝞"
	elseif vol < 67 then
		return "󰖀"
	else
		return "󰕾"
	end
end
local icon_textbox = wibox.widget({
	text = volume_icon(0, false),
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
	-- bar_shape = gears.shape.rounded_bar,
	bar_height = 10,
	bar_color = "#313244",
	bar_active_color = COL_VOLUME,
	handle_color = COL_VOLUME,
	-- handle_shape = gears.shape.circle,
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
local function update_ui(vol, muted)
	icon_textbox.text = volume_icon(vol, muted)
	value_label.text = muted and "Muted" or (vol .. "%")
	slider:set_value(vol)
end
local function refresh()
	awful.spawn.easy_async_with_shell(
		"pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1",
		function(stdout)
			local vol = tonumber(stdout:match("%d+")) or 0
			awful.spawn.easy_async_with_shell("pactl get-sink-mute @DEFAULT_SINK@", function(mute_out)
				local muted = mute_out:match("yes") ~= nil
				update_ui(vol, muted)
			end)
		end
	)
end
slider:connect_signal("property::value", function(s)
	local v = math.floor(s:get_value())
	awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ " .. v .. "%")
	awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ 0")
	value_label.text = v .. "%"
	icon_textbox.text = volume_icon(v, false)
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
