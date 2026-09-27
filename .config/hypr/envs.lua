-- envs.lua
-- NOTE (Arch wiki): Do NOT put env vars here if you use uwsm.
-- Use ~/.config/uwsm/env and ~/.config/uwsm/env-hyprland instead.
-- If you're NOT using uwsm, these are fine here.

-- Cursor
-- hl.env("XCURSOR_SIZE", "22")
-- hl.env("HYPRCURSOR_SIZE", "22")
-- hl.env("QT_CURSOR_SIZE", "22")
-- hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
-- hl.env("XCURSOR_THEME", "BreezeX-RosePine-Linux")
-- hl.env("HYPRCURSOR_THEME", "macOS-hypr")
-- hl.env("XCURSOR_THEME", "macOS-hypr")
-- hl.env("QT_CURSOR_THEME", "macOS-hypr")

hl.env("XCURSOR_SIZE", "22")
hl.env("HYPRCURSOR_SIZE", "22")
hl.env("QT_CURSOR_SIZE", "22")

hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("QT_CURSOR_THEME", "Adwaita")

-- Force Wayland
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Dark mode
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- NVIDIA
hl.env("NVD_BACKEND", "direct")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("WLR_RENDERER", "vulkan")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- Desktop / portals
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Scaling & UI Overrides
hl.env("GDK_SCALE", "1")

