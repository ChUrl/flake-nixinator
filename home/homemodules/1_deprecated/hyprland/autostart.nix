{
  lib,
  pkgs,
  config,
  hyprland,
}:
builtins.concatLists [
  (lib.optionals hyprland.dunst.enable ["dunst"]) # Notifications
  (lib.optionals hyprland.hyprpanel.enable ["hyprpanel"]) # Panel
  (lib.optionals hyprland.caelestia.enable ["caelestia shell"]) # Panel/Shell # TODO: Crashes on startup
  [
    # Start clipboard management
    "wl-paste -t text --watch clipman store --no-persist"
    "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""

    "hyprctl setcursor ${config.home.pointerCursor.name} ${builtins.toString config.home.pointerCursor.size}"
    "hyprsunset --identity"

    # HACK: Hyprland doesn't set the xwayland/x11 keymap correctly
    "setxkbmap -layout ${hyprland.keyboard.layout} -variant ${hyprland.keyboard.variant} -option ${hyprland.keyboard.option} -model pc104"

    # HACK: Flatpak doesn't find applications in the system PATH
    "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"

    # Provide a polkit authentication UI.
    # This is used for example when running systemd commands without root.
    # "systemctl --user start hyprpolkitagent.service"
    # "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
    "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
  ]
]
