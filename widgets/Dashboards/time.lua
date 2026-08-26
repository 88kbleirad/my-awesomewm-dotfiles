local wibox = require("wibox")

local time_widget = wibox.widget.textclock("%H:%M:%S", 1)
time_widget.font = "Digital-7 Italic 60"
time_widget.align = "center"
time_widget.valign = "center"

return time_widget
