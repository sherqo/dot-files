-- startup.lua

hl.on("hyprland.start", function()
    hl.exec_cmd("swaybg -i ~/media/img/wallpapers/wallhaven-y8vlyk.jpg -m fill")
    hl.exec_cmd("waybar")
    hl.exec_cmd("wl-paste --watch clipvault store")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("mkdir -p ~/gdrive && rclone mount gdrive: ~/gdrive --vfs-cache-mode full --vfs-cache-max-size 15G --vfs-cache-max-age 2160h --dir-cache-time 72h --attr-timeout 24h --poll-interval 30s --vfs-read-chunk-size 128M --buffer-size 64M --vfs-fast-fingerprint --daemon")

    -- Cursor setup
    -- hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine-Linux")
    -- hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 16")
    -- hl.exec_cmd("hyprctl setcursor BreezeX-RosePine-Linux 16")
    
    -- fix screen sharing after xdg-desktop-portal 1.22 
    hl.exec_cmd("/usr/lib/xdg-desktop-portal &")
end)
