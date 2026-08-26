local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

local has_overflow, overflow_err = pcall(require, "wibox.layout.overflow")

local has_grid = pcall(require, "wibox.layout.grid")

local dpi = beautiful.xresources and beautiful.xresources.apply_dpi or function(x)
	return x
end

-- Theme / constants
local COLORS = {
	bg = beautiful.bg_normal or "#1e1e1e",
	panel_bg = "#1e1e1e",
	border = beautiful.border_color_normal or "#3c3c3c",
	fg = beautiful.fg_normal or "#e0e0e0",
	fg_dim = beautiful.fg_minimize or "#9a9a9a",
	btn_bg = beautiful.bg_focus or "#2a2a2a",
	btn_bg_hover = beautiful.bg_urgent or "#3a3a3a",
}

local SQUARE = gears.shape.rectangle

-- Notification history log
local NotificationLog = {}
NotificationLog.__index = NotificationLog

function NotificationLog.new(max_items)
	local self = setmetatable({}, NotificationLog)
	self.items = {}
	self.max_items = max_items or 200
	self._listeners = {}

	naughty.connect_signal("added", function(n)
		self:add({
			title = (n.title and n.title ~= "") and n.title or (n.app_name or "Notification"),
			content = n.message or n.text or "",
			app = n.app_name or "",
			icon = n.icon or n.app_icon,
			time = os.time(),
		})
	end)

	return self
end

function NotificationLog:add(entry)
	table.insert(self.items, 1, entry)
	while #self.items > self.max_items do
		table.remove(self.items)
	end
	self:_notify()
end

function NotificationLog:clear()
	self.items = {}
	self:_notify()
end

function NotificationLog:on_change(fn)
	table.insert(self._listeners, fn)
end

function NotificationLog:_notify()
	for _, fn in ipairs(self._listeners) do
		fn()
	end
end

-- Time bucketing: Today / Yesterday / Last week / Last month / Last year

local function start_of_day(t)
	local d = os.date("*t", t)
	d.hour, d.min, d.sec = 0, 0, 0
	return os.time(d)
end

local function bucket_for(ts)
	local now = os.time()
	local today0 = start_of_day(now)
	local diff_days = math.floor((today0 - start_of_day(ts)) / 86400)

	if diff_days <= 0 then
		return "Today", 0
	elseif diff_days == 1 then
		return "Yesterday", 1
	elseif diff_days <= 7 then
		return "Last week", 2
	elseif diff_days <= 31 then
		return "Last month", 3
	else
		return "Last year", 4
	end
end

-- Groups items into ordered { {label=, items={...}}, ... }
local function group_by_time(items)
	local order = {}
	local seen = {}
	local groups = {}

	for _, entry in ipairs(items) do
		local label, rank = bucket_for(entry.time)
		if not seen[label] then
			seen[label] = true
			groups[label] = { label = label, rank = rank, items = {} }
			table.insert(order, label)
		end
		table.insert(groups[label].items, entry)
	end

	table.sort(order, function(a, b)
		return groups[a].rank < groups[b].rank
	end)

	local result = {}
	for _, label in ipairs(order) do
		table.insert(result, groups[label])
	end
	return result
end

-- Small UI helpers
local function divider()
	return wibox.widget({
		forced_height = dpi(1),
		color = "#cdd6f4",
		widget = wibox.widget.separator,
	})
end

local function section_header(text)
	return wibox.widget({
		{
			markup = "<span foreground='" .. "#cdd6f4" .. "'>" .. gears.string.xml_escape(text) .. "</span>",
			font = "BigBlueTermPlus Nerd Font Propo 14",
			widget = wibox.widget.textbox,
		},
		left = dpi(4),
		top = dpi(4),
		bottom = dpi(6),
		widget = wibox.container.margin,
	})
end

local function notification_row(entry)
	local icon_box = wibox.widget({
		{
			{
				image = entry.icon,
				resize = true,
				forced_width = dpi(48),
				forced_height = dpi(48),
				widget = wibox.widget.imagebox,
			},
			margin = dpi(4),
			widget = wibox.container.margin,
		},
		shape = SQUARE,
		bg = "#1e1e2e",
		forced_width = dpi(64),
		forced_height = dpi(64),
		widget = wibox.container.background,
	})

	local text_box = wibox.widget({
		{
			{
				{
					markup = "<b>" .. gears.string.xml_escape(entry.title) .. "</b>",

					widget = wibox.widget.textbox,
				},
				{
					markup = gears.string.xml_escape(entry.content),
					widget = wibox.widget.textbox,
				},
				spacing = dpi(2),
				layout = wibox.layout.fixed.vertical,
			},
			fg = "#cdd6f4",
			widget = wibox.container.background,
		},
		left = dpi(14),
		widget = wibox.container.margin,
	})

	local row = wibox.widget({
		icon_box,
		text_box,
		spacing = dpi(8),
		layout = wibox.layout.fixed.horizontal,
	})

	return wibox.widget({
		{
			{
				row,
				margin = dpi(12),
				widget = wibox.container.margin,
			},
			divider(),
			layout = wibox.layout.fixed.vertical,
		},
		widget = wibox.container.background,
	})
end

local function empty_state()
	return wibox.widget({
		{
			markup = "<span foreground='" .. "#cdd6f4" .. "'>No notifications</span>",
			align = "center",
			widget = wibox.widget.textbox,
		},
		top = dpi(24),
		bottom = dpi(24),
		widget = wibox.container.margin,
	})
end

-- Power action button (square, tooltip on hover, click = execute)

local function power_button(label, icon_path, on_click)
	local icon_color = "#1e1e2e"
	local icon_surface = gears.color.recolor_image(icon_path, icon_color)

	local icon_widget = wibox.widget({
		image = icon_surface,
		resize = true,
		forced_width = dpi(100),
		forced_height = dpi(100),
		widget = wibox.widget.imagebox,
	})

	local widget = wibox.widget({
		{
			icon_widget,
			halign = "center",
			valign = "center",
			widget = wibox.container.place,
		},
		shape = SQUARE,
		bg = "#cdd6f4",
		fg = "#1e1e2e",
		forced_width = dpi(170),
		forced_height = dpi(170),
		widget = wibox.container.background,
	})

	widget:connect_signal("mouse::enter", function()
		widget.bg = "#89b4fa"
	end)
	widget:connect_signal("mouse::leave", function()
		widget.bg = "#cdd6f4"
	end)

	widget:buttons(gears.table.join(awful.button({}, 1, function()
		on_click()
	end)))

	return widget
end

-- Public constructor
local function new(args)
	args = args or {}
	local log = NotificationLog.new(args.max_history or 200)

	-- Power action panel

	local hover_text = wibox.widget({
		markup = "<b>ダリエル</b>",
		font = "BigBlueTermPlus Nerd Font Propo 24",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local hover_label = wibox.widget({
		{
			hover_text,
			bottom = 10,
			widget = wibox.container.margin,
		},
		fg = "#cdd6f4",
		widget = wibox.container.background,
	})

	local function set_hover(text)
		hover_text.markup = "<b>" .. gears.string.xml_escape(text) .. "</b>"
	end

	local function reset_hover()
		set_hover("ダリエル")
	end

	local function make_btn(label, icon_path, cmd)
		local btn = power_button(label, icon_path, function()
			awful.spawn(cmd)
		end)
		btn:connect_signal("mouse::enter", function()
			set_hover(label)
		end)
		btn:connect_signal("mouse::leave", reset_hover)
		return btn
	end

	local icon_dir = os.getenv("HOME") .. "/.config/awesome/icons/"
	local btn_shutdown = make_btn("SHUT DOWN", icon_dir .. "power.svg", "systemctl poweroff")
	local btn_reboot = make_btn("REBOOT", icon_dir .. "refresh-ccw.svg", "systemctl reboot")
	local btn_lock =
		make_btn("LOOK SCREEN", icon_dir .. "lock.svg", os.getenv("HOME") .. "/.config/awesome/scripts/lock.sh")
	local btn_suspend = make_btn("SUSPEND", icon_dir .. "moon.svg", "systemctl suspend")

	local power_grid
	if has_grid then
		power_grid = wibox.widget({
			layout = wibox.layout.grid,
			forced_num_cols = 2,
			forced_num_rows = 2,
			homogeneous = true,
			expand = false,
			spacing = 15,
		})
		power_grid:add_widget_at(btn_shutdown, 1, 1, 1, 1)
		power_grid:add_widget_at(btn_reboot, 1, 2, 1, 1)
		power_grid:add_widget_at(btn_lock, 2, 1, 1, 1)
		power_grid:add_widget_at(btn_suspend, 2, 2, 1, 1)
	else
		power_grid = wibox.widget({
			{
				btn_shutdown,
				btn_reboot,
				spacing = 10,
				homogeneous = true,
				layout = wibox.layout.fixed.horizontal,
			},
			{
				btn_lock,
				btn_suspend,
				spacing = 10,
				homogeneous = true,
				layout = wibox.layout.fixed.horizontal,
			},
			spacing = 10,
			layout = wibox.layout.fixed.vertical,
		})
	end

	local power_grid_wrapped = wibox.widget({
		{
			power_grid,
			halign = "center",
			valign = "center",
			widget = wibox.container.place,
		},
		left = 20,
		right = 20,
		top = 16,
		bottom = 16,
		widget = wibox.container.margin,
	})

	local power_panel = wibox.widget({
		{
			power_grid_wrapped,
			hover_label,
			layout = wibox.layout.fixed.vertical,
		},
		margin = 10,
		widget = wibox.container.margin,
	})
	power_panel = wibox.widget({
		power_panel,
		shape = SQUARE,
		bg = "#1e1e2e",
		widget = wibox.container.background,
	})

	-- Notification history panel
	local history_list = wibox.widget({
		layout = wibox.layout.fixed.vertical,
	})

	local function rebuild_history()
		history_list:reset()

		if #log.items == 0 then
			history_list:add(empty_state())
			return
		end

		local groups = group_by_time(log.items)
		for _, group in ipairs(groups) do
			history_list:add(section_header(group.label))
			for _, entry in ipairs(group.items) do
				history_list:add(notification_row(entry))
			end
		end
	end

	log:on_change(rebuild_history)
	rebuild_history()

	local history_header = wibox.widget({
		{
			{
				markup = "<b>NOTIFICATION HISTORY</b>",
				font = "BigBlueTermPlus Nerd Font Propo 20",
				widget = wibox.widget.textbox,
			},
			fg = "#cdd6f4",
			widget = wibox.container.background,
		},
		left = 10,
		top = 8,
		bottom = 15,
		widget = wibox.container.margin,
	})

	local history_box = wibox.widget({
		{
			history_list,
			margin = 10,
			widget = wibox.container.margin,
		},
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, dpi(1))
		end,
		shape_border_width = dpi(1),
		shape_border_color = "#cdd6f4",
		bg = "#1e1e2e",
		widget = wibox.container.background,
	})

	local history_panel = wibox.widget({
		{
			history_header,
			history_box,
			spacing = dpi(6),
			layout = wibox.layout.fixed.vertical,
		},
		margin = dpi(10),
		widget = wibox.container.margin,
	})

	-- Root widget
	local root = wibox.widget({
		layout = wibox.layout.align.vertical,
		expand = "inside",
	})
	root.second = history_panel
	root.third = power_panel

	root = wibox.widget({
		root,
		shape = SQUARE,
		bg = "#1e1e2e",
		widget = wibox.container.background,
	})

	-- Optional ready-made popup wrapper
	local popup = awful.popup({
		widget = root,
		ontop = true,
		visible = false,
		shape = SQUARE,
		screen = args.screen,
		placement = args.placement or function(w)
			awful.placement.top_right(w, { margins = { top = dpi(40), right = dpi(10) } })
		end,
	})

	return {
		widget = root,
		popup = popup,
		log = log,
		toggle = function()
			popup.visible = not popup.visible
		end,
	}
end

return setmetatable({ new = new }, {
	__call = function(_, ...)
		return new(...)
	end,
})
