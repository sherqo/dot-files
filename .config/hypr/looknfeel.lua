-- Refer to https://wiki.hyprland.org/Configuring/Variables/

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    ecosystem = {
        no_update_news = true,
    },

    general = {
        gaps_in = 2.5,
        gaps_out = 2.5,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(ffffffff)", "rgba(d6ebffff)" }, angle = 35 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = true,
        layout = "master",
    },

    decoration = {
        rounding = 1,
        inactive_opacity = 0.95,
        active_opacity = 1,
        blur = {
            enabled = true,
            size = 2,
            passes = 3,
            new_optimizations = true,
            xray = true,
            ignore_opacity = true,
        },
        -- shadow.ignore_window removed in 0.55, now default behavior
    },

    group = {
        col = {
            border_active          = { colors = { "rgba(ffffffff)", "rgba(d6ebffff)" }, angle = 35 },
            border_inactive        = "rgba(595959aa)",
            border_locked_active   = "rgba(ff5555aa)",
            border_locked_inactive = "rgba(555555aa)",
        },
        groupbar = {
            font_size             = 12,
            font_family           = "monospace",
            font_weight_active    = "ultraheavy",
            font_weight_inactive  = "normal",
            indicator_height      = 0,
            height                = 18,
            gaps_in               = 5,
            gaps_out              = 0,
            text_color            = "rgb(ffffff)",
            text_color_inactive   = "rgba(ffffff90)",
            col = {
                active   = "rgba(00000040)",
                inactive = "rgba(00000020)",
            },
            gradients                 = true,
            gradient_rounding         = 0,
            gradient_round_only_edges = false,
        },
    },

    dwindle = {
        preserve_split = true,
        force_split = 2,
        -- pseudotile removed in 0.55
    },

    layout = {
        single_window_aspect_ratio           = "10 6",
        single_window_aspect_ratio_tolerance = 0,
    },

    master = {
        new_status       = "slave",
        allow_small_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        focus_on_activate        = true,
        anr_missed_pings         = 3,
        key_press_enables_dpms   = true,
        mouse_move_enables_dpms  = true,
        on_focus_under_fullscreen = 1,
        vrr = 0,
        render_unfocused_fps = 12,
        -- vfr moved to debug category in 0.55, don't set it here
    },

    cursor = {
        hide_on_key_press = true,
    },

    render = {
        direct_scanout = 2,
        -- cm_fs_passthrough removed in 0.55, handled automatically
    },
})

-- Animations
hl.curve("easeOutQuint",    { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic",  { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",          { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear",    { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick",           { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global",         enabled = true, speed = 0.1,  bezier = "default" })
hl.animation({ leaf = "windows",        enabled = true, speed = 0.08, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",      enabled = true, speed = 0.4,  bezier = "easeOutQuint", style = "popin 70%" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 0.08, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",         enabled = true, speed = 0.1,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",        enabled = true, speed = 0.1,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",           enabled = true, speed = 0.1,  bezier = "quick" })
hl.animation({ leaf = "layers",         enabled = true, speed = 0.08, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",       enabled = true, speed = 0.1,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",      enabled = true, speed = 0.08, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",   enabled = true, speed = 0.1,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",  enabled = true, speed = 0.1,  bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",     enabled = false, speed = 0.8,  bezier = "easeOutQuint" })
