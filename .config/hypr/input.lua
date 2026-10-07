-- See https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
    input = {
        kb_layout = "us, ara(mac)",
        kb_options = "grp:shifts_toggle,caps:escape",
        repeat_rate = 40,
        repeat_delay = 250,
        numlock_by_default = true,
        sensitivity = -0.7,
        natural_scroll = true,
        scroll_factor = 2,

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            scroll_factor = 0.4,
        },
    },
})

-- Touchpad gesture: 3-finger horizontal swipe to switch workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
