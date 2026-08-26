local awful = require("awful")
local naughty = require("naughty")

local screenshot = {}

-- Directory save image
local save_dir = os.getenv("HOME") .. "/Pictures/Screenshots-X11/"
os.execute("mkdir -p " .. save_dir)

local function notify(msg)
	naughty.notify({
		title = "Screenshot",
		text = msg,
		timeout = 2,
	})
end

-- Full screenshot
function screenshot.take_full()
	local filename = save_dir .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
	awful.spawn.easy_async_with_shell("maim -u '" .. filename .. "'", function()
		notify("Saved: " .. filename)
	end)
end

-- Area screenshot, savefile in clipboard
function screenshot.take_area()
	local filename = save_dir .. os.date("%Y-%m-%d_%H-%M-%S") .. "_area.png"
	awful.spawn.easy_async_with_shell(
		"maim -s -u '" .. filename .. "' && xclip -selection clipboard -t image/png -i '" .. filename .. "'",
		function()
			notify("Area saved & copied: " .. filename)
		end
	)
end

-- Window active screenshot, savefile
function screenshot.take_window()
	local filename = save_dir .. os.date("%Y-%m-%d_%H-%M-%S") .. "_window.png"
	awful.spawn.easy_async_with_shell("maim -u -i $(xdotool getactivewindow) '" .. filename .. "'", function()
		notify("Window saved: " .. filename)
	end)
end

return screenshot
