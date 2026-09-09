-- bindings/tiling.lua

local function d(desc) return { description = desc } end

-- ─── Close windows ─────────────────────────────────────────────────────────
hl.bind("SUPER + Q",         hl.dsp.window.close(),                      d("Close active window"))
hl.bind("SUPER + CTRL + Q",  hl.dsp.window.kill(),                       d("Force kill active window"))
hl.bind("SUPER + W", hl.dsp.send_shortcut({ mods = "CTRL", key = "W" }), { repeating = true, desc = "Close tab" })
-- ─── Tiling control ────────────────────────────────────────────────────────
hl.bind("SUPER + SHIFT + L", hl.dsp.window.float({ action = "toggle" }), d("Toggle floating/tiling"))
hl.bind("SUPER + F",         hl.dsp.window.fullscreen({ mode = 0 }),     d("Fullscreen"))
hl.bind("SUPER + CTRL + F",  hl.dsp.window.fullscreen_state({ client = 0, internal = 2 }), d("Tiled fullscreen"))
hl.bind("SUPER + ALT + F",   hl.dsp.window.fullscreen({ mode = 1 }),     d("Full width"))

-- ─── Focus movement ────────────────────────────────────────────────────────
hl.bind("SUPER + LEFT",  hl.dsp.focus({ direction = "left" }),  d("Focus left"))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "right" }), d("Focus right"))
hl.bind("SUPER + UP",    hl.dsp.focus({ direction = "up" }),    d("Focus up"))
hl.bind("SUPER + DOWN",  hl.dsp.focus({ direction = "down" }),  d("Focus down"))
hl.bind("SUPER + H",     hl.dsp.focus({ direction = "left" }),  d("Focus left"))
hl.bind("SUPER + L",     hl.dsp.focus({ direction = "right" }), d("Focus right"))
hl.bind("SUPER + K",     hl.dsp.focus({ direction = "up" }),    d("Focus up"))
hl.bind("SUPER + J",     hl.dsp.focus({ direction = "down" }),  d("Focus down"))

-- ─── Workspace switching ───────────────────────────────────────────────────
for i = 1, 10 do
    local key = "code:" .. (9 + i)   -- code:10 = 1, code:19 = 0
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }),                        d("Switch to workspace " .. i))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }),   d("Move window to workspace " .. i))
end

-- Special workspace H
hl.bind("SUPER + CTRL + H",   hl.dsp.workspace.toggle_special("H"),                        d("Toggle special workspace H"))
hl.bind("SUPER + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "special:H" }),              d("Move window to special workspace H"))

-- Workspace cycling
hl.bind("SUPER + TAB",         hl.dsp.focus({ workspace = "e+1" }),      d("Next workspace"))
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }),      d("Previous workspace"))
hl.bind("SUPER + CTRL + TAB",  hl.dsp.focus({ workspace = "previous" }), d("Former workspace"))

-- ─── Swap windows ──────────────────────────────────────────────────────────
hl.bind("SUPER + SHIFT + LEFT",  hl.dsp.window.swap({ direction = "l" }), d("Swap left"))
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }), d("Swap right"))
hl.bind("SUPER + SHIFT + UP",    hl.dsp.window.swap({ direction = "u" }), d("Swap up"))
hl.bind("SUPER + SHIFT + DOWN",  hl.dsp.window.swap({ direction = "d" }), d("Swap down"))
hl.bind("SUPER + ALT + h",     hl.dsp.window.swap({ direction = "l" }), d("Swap left"))
hl.bind("SUPER + ALT+ l",     hl.dsp.window.swap({ direction = "r" }), d("Swap right"))
hl.bind("SUPER + ALT + k",     hl.dsp.window.swap({ direction = "u" }), d("Swap up"))
hl.bind("SUPER + ALT + j",     hl.dsp.window.swap({ direction = "d" }), d("Swap down"))

-- ─── Cycle windows ─────────────────────────────────────────────────────────
hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(),              d("Cycle to next window"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ prev = true }), d("Cycle to prev window"))

-- ─── Resize active window ──────────────────────────────────────────────────
hl.bind("SUPER + code:20",         hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true, description = "Shrink width" })
hl.bind("SUPER + code:21",         hl.dsp.window.resize({ x =  50, y = 0, relative = true }), { repeating = true, description = "Expand width" })
hl.bind("SUPER + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true, description = "Shrink height" })
hl.bind("SUPER + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y =  50, relative = true }), { repeating = true, description = "Expand height" })

-- ─── Mouse move/resize ─────────────────────────────────────────────────────
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- ─── Groups ────────────────────────────────────────────────────────────────
hl.bind("SUPER + G",             hl.dsp.group.toggle(),               d("Toggle group"))
hl.bind("SUPER + ALT + G",       hl.dsp.window.move({ out_of_group = true }), d("Move window out of group"))
hl.bind("SUPER + ALT + LEFT",    hl.dsp.window.move({ into_group = "l" }), d("Move into group left"))
hl.bind("SUPER + ALT + RIGHT",   hl.dsp.window.move({ into_group = "r" }), d("Move into group right"))
hl.bind("SUPER + ALT + UP",      hl.dsp.window.move({ into_group = "u" }), d("Move into group up"))
hl.bind("SUPER + ALT + DOWN",    hl.dsp.window.move({ into_group = "d" }), d("Move into group down"))

hl.bind("SUPER + ALT + SHIFT + H",    hl.dsp.window.move({ into_group = "l" }), d("Move into group left"))
hl.bind("SUPER + ALT + SHIFT + L",   hl.dsp.window.move({ into_group = "r" }), d("Move into group right"))
hl.bind("SUPER + ALT + SHIFT + K",      hl.dsp.window.move({ into_group = "u" }), d("Move into group up"))
hl.bind("SUPER + ALT + SHIFT + J",    hl.dsp.window.move({ into_group = "d" }), d("Move into group down"))

hl.bind("SUPER + ALT + TAB",     hl.dsp.group.next(),                 d("Next window in group"))
hl.bind("SUPER + ALT + SHIFT + TAB", hl.dsp.group.prev(),             d("Previous window in group"))

-- Activate group window by number
for i = 1, 5 do
    hl.bind("SUPER + ALT + " .. i, hl.dsp.group.active({ index = i }), d("Switch to group window " .. i))
end
