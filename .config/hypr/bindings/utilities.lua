-- bindings/utilities.lua

local function d(desc) return { description = desc } end

-- ─── Terminal ──────────────────────────────────────────────────────────────
hl.bind("SUPER + Return", hl.dsp.exec_cmd("alacritty"), d("Terminal"))

-- ─── App launcher ──────────────────────────────────────────────────────────
-- Toggle tofi-drun (kill if running, else launch)
hl.bind("SUPER + Space", hl.dsp.exec_cmd("tofi-drun"), d("Launch apps"))

-- ─── Aesthetics ────────────────────────────────────────────────────────────
hl.bind("SUPER + SHIFT + BackSpace", function()
    local handle = io.popen("hyprctl activewindow -j")
    local json = handle:read("*a")
    handle:close()
    -- Extract address field from JSON (no external dep needed for this)
    local addr = json:match('"address"%s*:%s*"(0x%x+)"')
    if addr then
        hl.exec_cmd('hyprctl dispatch setprop "address:' .. addr .. '" opaque toggle')
    end
end, d("Toggle window transparency"))

hl.bind("SUPER + ALT + B", function()
    local handle = io.popen("pgrep -x waybar")
    local result = handle:read("*a")
    handle:close()
    if result ~= "" then
        hl.exec_cmd("pkill waybar")
    else
        hl.exec_cmd("waybar")
    end
end, d("Toggle Waybar"))

hl.bind("SUPER + CTRL + BackSpace", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
    end, { timeout = 300, type = "oneshot" })
end, { locked = true, description = "Turn all screens off" })

-- ─── Video wallpaper toggle ───────────────────────────────────────────────────
hl.bind("SUPER + CTRL + W", function()
    local handle = io.popen("pgrep -x mpvpaper")
    local result = handle:read("*a")
    handle:close()
    if result ~= "" then
        hl.exec_cmd("pkill mpvpaper")
    else
        hl.exec_cmd('mpvpaper DP-1 -o "no-audio loop" ~/media/img/wallpapers/vid/GOJO-VS-SUKUNA-WALLPAPEP1080p.mp4')
    end
end, d("Toggle live wallpaper"))

-- ─── Power / Lock ──────────────────────────────────────────────────────────
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("hyprlock"), d("Lock screen"))

-- ─── Notifications ─────────────────────────────────────────────────────────
hl.bind("SUPER + comma",         hl.dsp.exec_cmd("makoctl dismiss"),     d("Dismiss last notification"))
hl.bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("makoctl dismiss --all"), d("Dismiss all notifications"))
hl.bind("SUPER + CTRL + comma", function()
    hl.exec_cmd("makoctl mode -t do-not-disturb")
    -- Small delay then check mode and notify
    hl.exec_cmd([[sh -c 'sleep 0.1 && makoctl mode | grep -q do-not-disturb && notify-send "Silenced notifications" || notify-send "Enabled notifications"']])
end, d("Toggle DnD notifications"))

-- ─── Screenshots ───────────────────────────────────────────────────────────
hl.bind("Print",               hl.dsp.exec_cmd("~/bin/cmd-screenshot smart"),               d("Screenshot with editing"))
hl.bind("SUPER + CTRL + 1",    hl.dsp.exec_cmd("~/bin/cmd-screenshot smart --no-popup"), d("Screenshot (smart, no popup)"))
hl.bind("SUPER + CTRL + 2",    hl.dsp.exec_cmd("~/bin/cmd-screenshot full"),          d("Screenshot (full)"))
hl.bind("SUPER + CTRL + 3",    hl.dsp.exec_cmd("~/bin/cmd-screenshot ocr"),           d("Screenshot (OCR)"))
hl.bind("SUPER + CTRL + 4",    hl.dsp.exec_cmd("~/bin/cmd-screenshot smart"),         d("Screenshot (smart)"))
