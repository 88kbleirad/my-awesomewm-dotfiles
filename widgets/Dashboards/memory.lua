local gears = require("gears")
local wibox = require("wibox")

local memory_halfcircle = wibox.widget.base.make_widget()

local animation_pos = 0
local target_pos = 0

-- Used/total RAM in GB, for the small label under the percentage
local mem_used_gb = 0
local mem_total_gb = 0

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

memory_halfcircle.fit = function(_, context, max_w, max_h)
	return math.min(max_w, 260), math.min(max_h, 200)
end

memory_halfcircle.draw = function(_, context, cr, width, height)
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

	-- Small "used / total" label under the percentage
	local detail_text = string.format("%.1f / %.1f GB", mem_used_gb, mem_total_gb)
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

-- Read real memory usage from /proc/meminfo
local function read_mem_usage()
	local f = io.open("/proc/meminfo", "r")
	if not f then
		return nil
	end

	local mem_total, mem_available
	for line in f:lines() do
		local key, value = line:match("^(%a+):%s+(%d+)")
		if key == "MemTotal" then
			mem_total = tonumber(value)
		elseif key == "MemAvailable" then
			mem_available = tonumber(value)
		end
		if mem_total and mem_available then
			break
		end
	end
	f:close()

	if not mem_total or not mem_available or mem_total <= 0 then
		return nil
	end

	local used = mem_total - mem_available
	local usage = used / mem_total

	-- Values from /proc/meminfo are in kB; convert to GB for the label
	mem_used_gb = used / 1024 / 1024
	mem_total_gb = mem_total / 1024 / 1024

	return math.max(0, math.min(1, usage))
end

-- Poll real memory usage every 2s, updating the animation target
local poll_timer = gears.timer({
	timeout = 2,
	autostart = true,
	call_now = true,
	callback = function()
		local usage = read_mem_usage()
		if usage then
			target_pos = usage
		end
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
		memory_halfcircle:emit_signal("widget::redraw_needed")
	end,
})

return memory_halfcircle
