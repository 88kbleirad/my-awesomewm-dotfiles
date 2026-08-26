local gears = require("gears")
local wibox = require("wibox")

local cpu_halfcircle = wibox.widget.base.make_widget()

local animation_pos = 0
local target_pos = 0

local prev_idle, prev_total = nil, nil
local cpu_temp_c = nil

local THERMOMETER_ICON = "\u{f2c9}"

local function lerp_color(c1, c2, t)
	local r1, g1, b1 = tonumber(c1:sub(2, 3), 16), tonumber(c1:sub(4, 5), 16), tonumber(c1:sub(6, 7), 16)
	local r2, g2, b2 = tonumber(c2:sub(2, 3), 16), tonumber(c2:sub(4, 5), 16), tonumber(c2:sub(6, 7), 16)
	local r = math.floor(r1 + (r2 - r1) * t)
	local g = math.floor(g1 + (g2 - g1) * t)
	local b = math.floor(b1 + (b2 - b1) * t)
	return string.format("#%02x%02x%02x", r, g, b)
end

local function color_for_percent(p)
	if p < 0.5 then
		return lerp_color("#a6e3a1", "#f9e2af", p / 0.5)
	else
		return lerp_color("#f9e2af", "#f38ba8", (p - 0.5) / 0.5)
	end
end

cpu_halfcircle.fit = function(_, context, max_w, max_h)
	return math.min(max_w, 260), math.min(max_h, 200)
end

cpu_halfcircle.draw = function(_, context, cr, width, height)
	local padding = 20
	local cx = width / 2
	local cy = height - padding
	local r = math.min((width - 2 * padding) / 2, height - padding)
	local end_angle = math.pi + animation_pos * math.pi
	local current_color = color_for_percent(animation_pos)

	cr:new_path()
	cr:arc(cx, cy, r, math.pi, 2 * math.pi)
	cr:set_source(gears.color("#45475a"))
	cr:set_line_width(4)
	cr:stroke()

	if animation_pos > 0 then
		cr:new_path()
		cr:arc(cx, cy, r, math.pi, end_angle)
		cr:set_source(gears.color(current_color))
		cr:set_line_width(4)
		cr:stroke()
	end

	local hx = cx + r * math.cos(end_angle)
	local hy = cy + r * math.sin(end_angle)
	cr:new_path()
	cr:arc(hx, hy, 7, 0, 2 * math.pi)
	cr:set_source(gears.color(current_color))
	cr:fill()

	local percent_text = string.format("%d%%", math.floor(animation_pos * 100 + 0.5))
	cr:select_font_face("BigBlueTermPlus Nerd Font Propo", 0, 0)
	cr:set_font_size(42)
	local extents = cr:text_extents(percent_text)
	local text_y = cy - r * 0.25
	cr:set_source(gears.color("#cdd6e4"))
	cr:move_to(cx - extents.width / 2 - extents.x_bearing, text_y - extents.height / 2 - extents.y_bearing)
	cr:show_text(percent_text)

	-- Small "🌡 xx°C" label under the percentage
	if cpu_temp_c then
		local detail_text = string.format("%s %d°C", THERMOMETER_ICON, math.floor(cpu_temp_c + 0.5))
		cr:select_font_face("Maple Mono NF CN", 0, 0)
		cr:set_font_size(17)
		local detail_extents = cr:text_extents(detail_text)
		local detail_y = text_y + extents.height * 1.15
		cr:set_source(gears.color("#a6adc8"))
		cr:move_to(
			cx - detail_extents.width / 2 - detail_extents.x_bearing,
			detail_y - detail_extents.height / 2 - detail_extents.y_bearing
		)
		cr:show_text(detail_text)
	end
end

-- Read real CPU usage from /proc/stat
local function read_cpu_usage()
	local f = io.open("/proc/stat", "r")
	if not f then
		return nil
	end
	local line = f:read("*l")
	f:close()
	if not line then
		return nil
	end

	local nums = {}
	for n in line:gmatch("%d+") do
		table.insert(nums, tonumber(n))
	end

	local idle = nums[4] + (nums[5] or 0)
	local total = 0
	for _, v in ipairs(nums) do
		total = total + v
	end

	if prev_idle == nil then
		prev_idle, prev_total = idle, total
		return nil
	end

	local diff_idle = idle - prev_idle
	local diff_total = total - prev_total
	prev_idle, prev_total = idle, total

	if diff_total <= 0 then
		return 0
	end

	local usage = (diff_total - diff_idle) / diff_total
	return math.max(0, math.min(1, usage))
end

-- Read CPU package temperature from /sys/class/thermal
local function find_cpu_thermal_zone()
	for zone = 0, 19 do
		local tf = io.open(string.format("/sys/class/thermal/thermal_zone%d/type", zone), "r")
		if tf then
			local ztype = tf:read("*l")
			tf:close()
			if ztype and ztype:lower():match("cpu") or (ztype and ztype:lower():match("pkg")) then
				return zone
			end
		end
	end
	return 0
end

local cpu_thermal_zone = find_cpu_thermal_zone()

local function read_cpu_temp()
	local vf = io.open(string.format("/sys/class/thermal/thermal_zone%d/temp", cpu_thermal_zone), "r")
	if not vf then
		return nil
	end
	local raw = vf:read("*l")
	vf:close()
	local millidegrees = tonumber(raw)
	if not millidegrees then
		return nil
	end
	return millidegrees / 1000
end

-- Poll real CPU usage + temperature every 2s
local poll_timer = gears.timer({
	timeout = 2,
	autostart = true,
	call_now = true,
	callback = function()
		local usage = read_cpu_usage()
		if usage then
			target_pos = usage
		end
		cpu_temp_c = read_cpu_temp()
	end,
})

-- Smoothly animate animation_pos towards target_pos at 60fps
local anim_timer = gears.timer({
	timeout = 0.016,
	autostart = true,
	call_now = false,
	callback = function()
		local diff = target_pos - animation_pos
		if math.abs(diff) < 0.001 then
			animation_pos = target_pos
		else
			animation_pos = animation_pos + diff * 0.08
		end
		cpu_halfcircle:emit_signal("widget::redraw_needed")
	end,
})

return cpu_halfcircle
