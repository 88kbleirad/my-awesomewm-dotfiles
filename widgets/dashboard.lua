local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local calendar_widget = require("widgets.Dashboards.calendar")
local time_widget = require("widgets.Dashboards.time")
local cpu_widget = require("widgets.Dashboards.cpu")
local memory_widget = require("widgets.Dashboards.memory")
local disk_widget = require("widgets.Dashboards.disk")
local battery_widget = require("widgets.Dashboards.battery")
local app_widget = require("widgets.Dashboards.app-box")
local volume_widget = require("widgets.Dashboards.volume")
local brightness_widget = require("widgets.Dashboards.brightness")

local dashboard_content = wibox.widget({
	{
		{
			calendar_widget,
			margins = 15,
			widget = wibox.container.margin,
		},
		{
			{
				{
					cpu_widget,
					strategy = "exact",
					width = 240,
					height = 175,
					widget = wibox.container.constraint,
				},
				top = 20,
				bottom = 20,
				widget = wibox.container.margin,
			},
			{
				{
					text = " CPU",
					font = "BigBlueTermPlus Nerd Font Propo Bold 17",
					align = "center",
					valign = "center",
					widget = wibox.widget.textbox,
				},
				fg = "#cdd6e4",
				widget = wibox.container.background,
			},
			layout = wibox.layout.fixed.vertical,
		},
		{
			{
				{
					{
						text = "HARDWARE",
						font = "BigBlueTermPlus Nerd Font Propo Bold 23",
						align = "center",
						valign = "center",
						widget = wibox.widget.textbox,
					},
					fg = "#cdd6e4",
					widget = wibox.container.background,
				},
				top = 17,
				widget = wibox.container.margin,
			},
			{
				{
					memory_widget,
					strategy = "exact",
					width = 240,
					height = 125,
					widget = wibox.container.constraint,
				},
				top = 21,
				bottom = 22,
				widget = wibox.container.margin,
			},
			{
				{
					text = " MEMORY",
					font = "BigBlueTermPlus Nerd Font Propo Bold 17",
					align = "center",
					valign = "center",
					widget = wibox.widget.textbox,
				},
				fg = "#cdd6e4",
				widget = wibox.container.background,
			},
			layout = wibox.layout.fixed.vertical,
		},
		{
			{
				{
					disk_widget,
					strategy = "exact",
					width = 240,
					height = 175,
					widget = wibox.container.constraint,
				},
				top = 20,
				bottom = 23,
				widget = wibox.container.margin,
			},
			{
				{
					text = " DISK",
					font = "BigBlueTermPlus Nerd Font Propo Bold 17",
					align = "center",
					valign = "center",
					widget = wibox.widget.textbox,
				},
				fg = "#cdd6e4",
				widget = wibox.container.background,
			},
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.fixed.horizontal,
	},
	{
		{
			{
				{
					time_widget,
					margins = 4,
					widget = wibox.container.margin,
				},
				strategy = "exact",
				width = 270,
				height = 150,
				widget = wibox.container.constraint,
			},
			bg = "#bac2de",
			fg = "#1e1e2e",
			widget = wibox.container.background,
		},
		{
			{

				{
					volume_widget,
					strategy = "exact",
					width = 410,
					height = 55,
					widget = wibox.container.constraint,
				},
				{
					brightness_widget,
					strategy = "exact",
					width = 410,
					height = 55,
					widget = wibox.container.constraint,
				},
				layout = wibox.layout.fixed.vertical,
			},
			strategy = "exact",
			width = 580,
			height = 300,
			widget = wibox.container.constraint,
		},
		{
			{
				app_widget,
				strategy = "exact",
				width = 50,
				height = 50,
				widget = wibox.container.constraint,
			},
			left = 10,
			right = 10,
			widget = wibox.container.margin,
		},

		{
			battery_widget,
			{
				image = os.getenv("HOME") .. "/.icons/battery-empty.png",
				resize = true,
				widget = wibox.widget.imagebox,
			},
			strategy = "exact",
			width = 65,
			height = 150,
			widget = wibox.container.constraint,
		},

		layout = wibox.layout.fixed.horizontal,
	},
	layout = wibox.layout.fixed.vertical,
})

return dashboard_content
