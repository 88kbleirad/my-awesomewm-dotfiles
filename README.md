# awesomewm-dotfiles

This is my awesomewm dotfile, I will tutorial you how to setup awesomewm dotfile.

## **1.Window Manager** 

Step 1: Install awesome 

+ If you using Arch/Cachy, you could making this way.

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

+ I using `betterlockscreen` and I will tutorial how to setup.

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

- Wibar

<center></center>![[Pasted image 20260826153401.png]]

+ Dashboard

<center></center>![[2026-08-26_15-34-50_area.png]]

+ Right Dashboard

<center></center>![[2026-08-26_15-37-11_area.png]]


+ Lock Screen 

<center></center>![[lock_blur 1.png]]
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

