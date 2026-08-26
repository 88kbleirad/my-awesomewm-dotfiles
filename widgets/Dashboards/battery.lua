local wibox = require("wibox")
local gears = require("gears")

local battery_draw = wibox.widget.base.make_widget()

battery_draw.level = 0
battery_draw.charging = false
battery_draw.w = 40
battery_draw.h = 70
battery_draw.outline = { 0x74 / 255, 0x74 / 255, 0x7a / 255 }
battery_draw.fill_color = { 0x74 / 255, 0xc7 / 255, 0xec / 255 }
battery_draw.low_color = { 0xf3 / 255, 0x8b / 255, 0xa8 / 255 }

function battery_draw:fit(_, width, height)
	return math.min(width, self.w), math.min(height, self.h)
end

function battery_draw:draw(_, cr, width, height)
	local w, h = width, height
	local border = math.max(2, w * 0.10)
	local cap_w = w * 0.40
	local cap_h = h * 0.06
	local body_top = cap_h
	local body_h = h - body_top
	local radius = w * 0.16

	cr:set_source_rgb(table.unpack(self.outline))
	cr:rectangle((w - cap_w) / 2, 0, cap_w, cap_h + border / 2)
	cr:fill()

	local x, y, bw, bh = border / 2, body_top, w - border, body_h - border
	cr:new_path()
	cr:arc(x + radius, y + radius, radius, math.pi, 3 * math.pi / 2)
	cr:arc(x + bw - radius, y + radius, radius, 3 * math.pi / 2, 2 * math.pi)
	cr:arc(x + bw - radius, y + bh - radius, radius, 0, math.pi / 2)
	cr:arc(x + radius, y + bh - radius, radius, math.pi / 2, math.pi)
	cr:close_path()
	cr:set_line_width(border)
	cr:set_source_rgb(table.unpack(self.outline))
	cr:stroke()

	local inset = border * 1.4
	local fx = x + inset
	local fy = y + inset
	local fw = bw - inset * 2
	local fh = bh - inset * 2
	local fill_h = fh * (self.level / 100)

	cr:save()
	cr:rectangle(fx, fy + (fh - fill_h), fw, fill_h)
	cr:clip()
	if self.level <= 20 and not self.charging then
		cr:set_source_rgb(table.unpack(self.low_color))
	else
		cr:set_source_rgb(table.unpack(self.fill_color))
	end
	cr:rectangle(fx, fy, fw, fh)
	cr:fill()
	cr:restore()
end

--  Real % Pin from system reality
local function find_battery_path()
	local handle = io.popen("ls /sys/class/power_supply/ 2>/dev/null")
	if not handle then
		return nil
	end
	for name in handle:lines() do
		if name:match("^BAT") then
			handle:close()
			return "/sys/class/power_supply/" .. name
		end
	end
	handle:close()
	return nil
end

local BAT_PATH = find_battery_path()

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*l")
	f:close()
	return content
end

local function read_battery()
	if not BAT_PATH then
		return nil, nil
	end
	local capacity = read_file(BAT_PATH .. "/capacity")
	local status = read_file(BAT_PATH .. "/status")
	return tonumber(capacity), status
end

local percent_text = wibox.widget({
	text = "--%",
	font = "BigBlueTermPlus Nerd Font Propo 9",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local battery_widget = wibox.widget({
	battery_draw,
	{
		{
			percent_text,
			valign = "center",
			halign = "center",
			widget = wibox.container.place,
		},
		fg = "#1e1e2e",
		widget = wibox.container.background,
	},
	layout = wibox.layout.stack,
})

local function update_battery()
	local capacity, status = read_battery()
	if not capacity then
		percent_text.text = "N/A"
		return
	end
	battery_draw.level = capacity
	battery_draw.charging = (status == "Charging")
	percent_text.text = capacity .. "%"
	battery_draw:emit_signal("widget::redraw_needed")
end

update_battery()

gears.timer({
	timeout = 15,
	autostart = true,
	call_now = false,
	callback = update_battery,
})

return battery_widget
