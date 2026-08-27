local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local M = {}
function M.create_slide_popup_from_left(content_widget)
	local screen = awful.screen.focused()
	local sw = screen.geometry.width
	local sh = screen.geometry.height
	local pw = math.floor(sw * 0.9)
	local ph = sh
	local y_pos = 0
	local popup = wibox({
		visible = false,
		ontop = true,
		type = "utility",
		screen = screen,
		width = pw,
		height = ph,
		x = -pw,
		y = y_pos,
		bg = beautiful.bg_normal or "#222222",
		fg = beautiful.fg_normal or "#ffffff",
		shape = gears.shape.rectangle,
		border_width = 0,
	})
	if not content_widget then
		content_widget = {
			layout = wibox.layout.align.vertical,
			{
				layout = wibox.layout.fixed.vertical,
				{
					widget = wibox.widget.textbox,
					text = "🎉 Popup mặc định (từ trái)",
					font = "sans 24",
					align = "center",
					valign = "center",
				},
			},
		}
	end
	popup:setup(content_widget)
	local state = "closed"
	local timer = nil
	local function stop_timer()
		if timer then
			timer:stop()
			timer = nil
		end
	end

	local function reset()
		stop_timer()
		popup.visible = false
		popup.x = pw
		state = "closed"
	end

	function popup.open()
		if state == "open" or state == "opening" then
			return
		end
		stop_timer()
		state = "opening"
		local start_x = -pw
		local end_x = 0
		popup.visible = true
		popup.x = start_x
		local duration = 0.4
		local steps = 30
		local step_time = duration / steps
		local step = 0
		timer = gears.timer({
			timeout = step_time,
			autostart = true,
			callback = function()
				step = step + 1
				local progress = step / steps
				local eased = (progress < 0.5) and (2 * progress * progress) or (1 - math.pow(-2 * progress + 2, 2) / 2)
				popup.x = start_x + (end_x - start_x) * eased
				if step >= steps then
					popup.x = end_x
					state = "open"
					stop_timer()
				end
			end,
		})
	end

	function popup.close()
		if state == "closed" or state == "closing" then
			return
		end
		stop_timer()
		state = "closing"
		local start_x = popup.x
		local end_x = -pw - 1100
		local duration = 0.4
		local steps = 25
		local step_time = duration / steps
		local step = 0
		timer = gears.timer({
			timeout = step_time,
			autostart = true,
			callback = function()
				step = step + 1
				local progress = step / steps
				local eased = (progress < 0.5) and (2 * progress * progress) or (1 - math.pow(-2 * progress + 2, 2) / 2)
				popup.x = start_x + (end_x - start_x) * eased
				if step >= steps then
					popup.x = end_x
					popup.visible = false
					state = "closed"
					stop_timer()
				end
			end,
		})
	end

	function popup.toggle()
		if state == "opening" then
			popup.close()
			if state == "closed" then
				reset()
			end
		else
			popup.open()
		end
	end

	return popup
end
return M
