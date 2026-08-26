local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local M = {}

function M.create_slide_popup_from_right(opts)
	local screen = awful.screen.focused()
	local sw = screen.geometry.width
	local sh = screen.geometry.height

	local width = opts.width or math.floor(sw * 0.5)
	local height = opts.height or sh
	local y = opts.y or 0
	local bg = opts.bg or beautiful.bg_normal or "#222222"
	local fg = opts.fg or beautiful.fg_normal or "#ffffff"
	local border_width = opts.border_width or 0
	local border_color = opts.border_color or beautiful.border_color or "#000000"
	local shape = opts.shape or gears.shape.rectangle
	local ontop = opts.ontop or true
	local widget = opts.widget

	if not widget then
		error("Bạn cần cung cấp widget cho popup")
	end

	-- Create popup
	local popup = wibox({
		visible = false,
		ontop = ontop,
		type = "utility",
		screen = screen,
		width = width,
		height = height,
		x = sw,
		y = y,
		bg = bg,
		fg = fg,
		shape = shape,
		border_width = border_width,
		border_color = border_color,
	})

	popup:setup(widget)

	-- Animation and state
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
		popup.x = sw
		state = "closed"
	end

	function popup.open()
		stop_timer()
		if state == "open" or state == "opening" then
			return
		end

		state = "opening"
		popup.visible = true
		popup.x = sw

		local start_x = sw
		local end_x = sw - width
		local duration = 0.3
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
		stop_timer()
		if state == "closed" or state == "closing" then
			return
		end

		state = "closing"
		local start_x = popup.x
		local end_x = sw
		local duration = 0.25
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
			reset()
		elseif state == "open" or state == "closing" then
			popup.close()
		elseif state == "closed" then
			popup.open()
		end
	end

	return popup
end

return M
