pcall(require, "luarocks.loader")
local beautiful = require("beautiful")
require("awful.autofocus")

require("error")

-- Terminal

-- Sort binds
require("binds.keybind")
require("binds.mouse")
-- Layout
require("layouts.layout")
-- Rule
require("rules.rule")

-- Theme
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/init.lua")

-- Widget
require("widgets.wallpaper")
require("widgets.wibar")
