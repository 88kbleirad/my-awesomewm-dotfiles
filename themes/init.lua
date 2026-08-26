local theme = {}
theme.useless_gap = 4

local gfs = require("gears.filesystem")
local gears = require("gears")
local themes_path = gfs.get_themes_dir()
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

theme.font = "MapleMono NF CN 12"

-- Color background and font
theme.bg_normal = "#222222"
theme.bg_focus = "#535d6c"
theme.bg_urgent = "#ff0000"
theme.fg_normal = "#aaaaaa"
theme.fg_focus = "#ffffff"

-- Border & titlebar
theme.border_width = dpi(2)
theme.border_color_normal = "#363a4f"
theme.border_color_active = "#1e1e2e"
theme.border_color_marked = "#91231c"
theme.titlebar_bg_normal = "#cdd6e4"
theme.titlebar_bg_focus = "#1e1e2e"

-- Systray
theme.systray_icon_spacing = 10
theme.systray_icon_size = 10
theme.bg_systray = "#1e1e2e"

-- Menu
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)

-- Layout icons
theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"

-- Notifications
theme.notification_font = "MapleMono NF CN 12"
theme.notification_bg = "#1e1e2e"
theme.notification_fg = "#cdd6f4"
theme.notification_border_width = 1
theme.notification_border_color = "#45475a"
theme.notification_opacity = 0.95
theme.notification_icon_size = 32
theme.notification_shape = function(cr, w, h)
	gears.shape.rounded_rect(cr, w, h, 12)
end
theme.notification_max_width = 420
theme.notification_max_height = 300

-- Wallpaper
theme.wallpaper = os.getenv("HOME") .. "/Pictures/cat-catpuccin.png"
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)

return theme
