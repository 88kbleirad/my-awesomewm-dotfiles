local awful = require("awful")
local ruled = require("ruled")
local wibox = require("wibox")
local naughty = require("naughty")

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	})

	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},
			name = {
				"Event Tester",
			},
			role = {
				"AlarmWindow",
				"ConfigManager",
				"pop-up",
			},
		},
		properties = { floating = true },
	})

	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = false },
	})
end)

-- Notifications
ruled.notification.connect_signal("request::rules", function()
	ruled.notification.append_rule({
		rule = {},
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
		},
	})
end)

naughty.connect_signal("request::display", function(n)
	naughty.layout.box({ notification = n })
end)

-- client.connect_signal("request::titlebars", function(c)
-- 	-- buttons for the titlebar
-- 	local buttons = {
-- 		awful.button({}, 1, function()
-- 			c:activate({ context = "titlebar", action = "mouse_move" })
-- 		end),
-- 		awful.button({}, 3, function()
-- 			c:activate({ context = "titlebar", action = "mouse_resize" })
-- 		end),
-- 	}
--
-- 	awful.titlebar(c).widget = {
-- 		{ -- Left
-- 			awful.titlebar.widget.iconwidget(c),
-- 			buttons = buttons,
-- 			layout = wibox.layout.fixed.horizontal,
-- 		},
-- 		{ -- Middle
-- 			{ -- Title
-- 				halign = "center",
-- 				widget = awful.titlebar.widget.titlewidget(c),
-- 			},
-- 			buttons = buttons,
-- 			layout = wibox.layout.flex.horizontal,
-- 		},
-- 		{ -- Right
-- 			awful.titlebar.widget.floatingbutton(c),
-- 			awful.titlebar.widget.maximizedbutton(c),
-- 			awful.titlebar.widget.stickybutton(c),
-- 			awful.titlebar.widget.ontopbutton(c),
-- 			awful.titlebar.widget.closebutton(c),
-- 			layout = wibox.layout.fixed.horizontal(),
-- 		},
-- 		layout = wibox.layout.align.horizontal,
-- 	}
-- end)
