local wibox = require("wibox")

local calendar_widget = wibox.widget({
	date = os.date("*t"),
	font = "BigBlueTermPlus Nerd Font Propo 14",
	spacing = 12,
	fn_embed = function(widget, flag, date)
		if flag == "focus" then
			return wibox.widget({
				widget,
				bg = "#89b4fa",
				fg = "#1e1e2e",
				widget = wibox.container.background,
			})
		elseif flag == "header" then
			return wibox.widget({
				widget,
				fg = "#89b4fa",
				font = "BigBlueTermPlus Nerd Font Propo 12",
				widget = wibox.container.background,
			})
		elseif flag == "weekday" then
			return wibox.widget({
				widget,
				fg = "#a6adc8",
				font = "BigBlueTermPlus Nerd Font Propo 9",
				widget = wibox.container.background,
			})
		end
		return widget
	end,
	widget = wibox.widget.calendar.month,
})

return calendar_widget
