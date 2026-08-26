# awesomewm-dotfiles

This is my AwesomeWM dotfiles repository. Below is a step-by-step guide on how to set it up.

## **1.Window Manager** 

Step 1: Install awesome 

+ If you are using Arch/CachyOS, you can install it like this:

```bash
yay -S awesomewm-git
```

Step 2: Add my-awesomewm-dotfiles from Github to .config.

```bash
cd ~/.config
git clone https://github.com/88kbleirad/my-awesomewm-dotfiles.git
mv my-awesomewm-dotfiles awesome
```

Step 3: Restart Awesome.

+ Restart with keybind.

```bash
Alt + Shift + r
```

+ Restart with Right Mouse.

```bash
Input Right Mouse -> Choose awesome in menuup -> Click restart 
```

## **2. Lock Screen**

+ I use `betterlockscreen`. Here's how to set it up:

Step 1: Install `betterlockscreen`.

```bash
yay -S betterlockscreen
```

Step 2: Create file `betterlockscreenrc` in `~/.config/betterlockscreen/`.

```bash
cd ~/.config/betterlockscreen
touch betterlockscreen
```

Step 3: Config file `betterlockscreenrc`.

+ This is my catpuccin-mocha config.

```bash
locktext="Enter password to unlock"
font="BigBlueTermPlus Nerd Font Propo"
time_format="%H:%M:%S"

bgcolor="1e1e2eff"
loginbox="1e1e2ecc"
loginshadow="11111b66"

ringcolor="b4befeff"
insidecolor="1e1e2ecc"
separatorcolor="6c7086ff"

ringvercolor="89b4faff"
insidevercolor="313244cc"
verifcolor="89b4faff"
veriftext="Checking..."

ringwrongcolor="f38ba8ff"
insidewrongcolor="45475acc"
wrongcolor="f38ba8ff"
wrongtext="Wrong Password!"

timecolor="cdd6f4ff"
greetercolor="cdd6f4ff"
layoutcolor="cdd6f4ff"

keyhlcolor="a6e3a1ff"
bshlcolor="f38ba8ff"
modifcolor="f9e2afff"

wallpaper_cmd="feh --bg-fill"
```

Step 4: On directory awesome, creative directory scripts and create file `lock.sh`

```bash
#!/usr/bin/env bash
betterlockscreen -u ~/.config/awesome/Pictures -q >/dev/null 2>&1
betterlockscreen -l dimblur
```

Step 5: Run script `lock.sh`

```bash
chmod +x ~/.config/awesome/scripts/lock.sh
.~/.config/awesome/scripts/lock.sh
or
cd ~/.config/awesome/scripts
./lock.sh
```
## **3. Demo/Screenshot**

<p align="center"><b>Wibar</b></p>
<p align="center">
  <img src="demo/wibar.png" width="800">
</p>

<p align="center"><b>Dashboard</b></p>
<p align="center">
  <img src="demo/dashboard.png" width="800">
</p>

<p align="center"><b>Right Dashboard</b></p>
<p align="center">
  <img src="demo/right-dashboard.png" width="400">
</p>

<p align="center"><b>Lock Screen</b></p>
<p align="center">
  <img src="demo/lockscreen.png" width="800">
</p>

## **4. Tree Directory** 

```
awesome/
├── binds
│   ├── keybind.lua
│   └── mouse.lua
├── effects
│   └── slide_from_right_to_left.lua
├── error.lua
├── layouts
│   └── layout.lua
├── lib
│   └── rubato
│       ├── easing.lua
│       ├── init.lua
│       ├── manager.lua
│       ├── rubato-1.2-1.rockspec
│       ├── subscribable.lua
│       └── timed.lua
├── main.lua
├── Pictures
│   ├── Rimuru_1.jpeg
│   ├── Rimuru_2.jpeg
│   ├── Rimuru_3.jpeg
│   ├── Rimuru_4.jpeg
│   ├── Rimuru_5.jpeg
│   ├── Rimuru_6.jpeg
│   ├── Rimuru_7.png
│   └── Rimuru_8.png
├── rc.lua
├── rc.lua.bak
├── README.md
├── rules
│   └── rule.lua
├── screenshot.lua
├── scripts
│   └── lock.sh
├── themes
│   └── init.lua
└── widgets
    ├── dashboard.lua
    ├── Dashboards
    │   ├── app-box.lua
    │   ├── battery.lua
    │   ├── brightness.lua
    │   ├── calendar.lua
    │   ├── cpu.lua
    │   ├── disk.lua
    │   ├── memory.lua
    │   ├── time.lua
    │   └── volume.lua
    ├── right-dashboard.lua
    ├── wallpaper.lua
    └── wibar.lua
```

## **5. Tech Stack**

- Lua, bash

