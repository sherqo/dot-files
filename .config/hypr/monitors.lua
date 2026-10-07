-- # See https://wiki.hyprland.org/Configuring/Monitors/

hl.monitor({ output = "DP-1",  mode = "1920x1080@75.03",  position = "0x0",       scale = 1,    cm = "auto", disabled = false })
hl.monitor({ output = "eDP-1", mode = "1920x1080@120.00", position = "auto-left", scale = 1.25, cm = "auto", disabled = false })

-- Workspace-to-monitor assignment via workspace rules
hl.workspace_rule({ workspace = "1",  monitor = "DP-1",   default = true })
hl.workspace_rule({ workspace = "2",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "3",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "4",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "5",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "6",  monitor = "DP-1" })
hl.workspace_rule({ workspace = "6",  monitor = "HDMI-A-1" })

hl.workspace_rule({ workspace = "7",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "8",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "9",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "10", monitor = "eDP-1", default = true })
