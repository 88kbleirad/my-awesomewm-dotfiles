local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local slide_right = require("effects.slide_from_right_to_left")
local slide_left = require("effects.slide_from_left_to_right")

require("awful.hotkeys_popup.keys")

modkey = "Mod1"

terminal = "wezterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
	},
})

local dashboard_content = require("widgets.dashboard")
local right_dashboard_content = require("widgets.right-dashboard")
local s = awful.screen.focused()
local dash = right_dashboard_content({ screen = s })

local dashboard_popup = awful.popup({
	widget = dashboard_content,
	minimum_width = 800,
	maximum_width = 1000,
	minimum_height = 100,
	maximum_height = 390,

	bg = "#1e1e2e",
	border_width = 0,
	ontop = true,
	visible = false,
	placement = function(c)
		awful.placement.top(c, {
			margins = { top = 8 },
			honor_workarea = true,
		})
	end,
})

local dashboard_icon_button = wibox.widget({
	{
		{
			image = beautiful.awesome_icon,
			resize = true,
			forced_width = 34,
			forced_height = 34,
			widget = wibox.widget.imagebox,
		},
		right = 4,
		widget = wibox.container.margin,
	},
	halign = "center",
	valign = "center",
	widget = wibox.container.place,
})

dashboard_icon_button:buttons(gears.table.join(awful.button({}, 1, function()
	dashboard_popup.visible = not dashboard_popup.visible
end)))

local left_custom = slide_left.create_slide_popup_from_left()

awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "v", function()
		left_custom.toggle()
	end, { description = "Left board custom", group = "awesome" }),
})

local right_dashboard_popup = slide_right.create_slide_popup_from_right({
	widget = dash,
	width = 500,
	height = 1080,
	bg = "#1e1e2e",
	ontop = true,
	duration_open = 0.4,
	duration_close = 0.4,
	steps = 20,
})

local right_dashboard_icon_button = wibox.widget({
	{
		{
			image = os.getenv("HOME") .. "/.config/awesome/icons/power.svg",
			resize = true,
			forced_width = 34,
			forced_height = 34,
			widget = wibox.widget.imagebox,
		},
		bg = "#00000000",
		widget = wibox.container.background,
	},
	halign = "center",
	valign = "center",
	widget = wibox.container.place,
})

right_dashboard_icon_button:buttons(gears.table.join(awful.button({}, 1, function()
	right_dashboard_popup.toggle()
end)))

awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "w", function()
		dashboard_popup.visible = not dashboard_popup.visible
	end, { description = "Toggle Dashboard", group = "awesome" }),
})

awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "e", function()
		right_dashboard_popup.toggle()
	end, { description = "Right Toggle Dashboard", group = "awesome" }),
})

screen.connect_signal("request::desktop_decoration", function(s)
	awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])

	s.mypromptbox = awful.widget.prompt()
	s.mylayoutbox = awful.widget.layoutbox({
		screen = s,
		buttons = {
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 4, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 5, function()
				awful.layout.inc(1)
			end),
		},
	})

	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = {
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({ modkey }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end),
			awful.button({}, 3, awful.tag.viewtoggle),
			awful.button({ modkey }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end),
		},
	})

	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		style = {
			bg_normal = "#00000000",
			bg_focus = "#00000000",
		},
		buttons = {
			awful.button({}, 1, function(c)
				c:activate({ context = "tasklist", action = "toggle_minization" })
			end),
			awful.button({}, 3, function()
				awful.menu.client_list({
					theme = {
						width = 500,
						height = 50,
						border_width = 0,
						bg_normal = "#00000000",
						bg_focus = "#00000000",
						fg_normal = "#cdd6f4",
						fg_focus = "#89b4fa",
					},
				})
			end),
			awful.button({}, 4, function()
				awful.client.focus.byidx(-1)
			end),
			awful.button({}, 5, function()
				awful.client.focus.byidx(1)
			end),
		},
	})

	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		width = 175,
		bg = "#00000000",
		widget = {

			{
				layout = wibox.layout.fixed.horizontal,
				dashboard_icon_button,
			},
			s.mytasklist,
			{
				layout = wibox.layout.fixed.horizontal,
				s.mylayoutbox,
				right_dashboard_icon_button,
			},
			layout = wibox.layout.align.horizontal,
		},
	})
end)
