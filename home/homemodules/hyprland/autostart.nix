{
  lib,
  pkgs,
  config,
  hyprland,
}:
builtins.concatLists [
  (lib.optionals hyprland.hyprpanel.enable ["hyprpanel"]) # Panel
  [
    "hyprctl setcursor ${config.home.pointerCursor.name} ${builtins.toString config.home.pointerCursor.size}"
    "hyprsunset --identity"
    "waypaper --restore"
    "fcitx5"

    # HACK: Hyprland doesn't set the xwayland/x11 keymap correctly
    "setxkbmap -layout ${hyprland.keyboard.layout} -variant ${hyprland.keyboard.variant} -option ${hyprland.keyboard.option} -model pc104"

    # HACK: Flatpak doesn't find applications in the system PATH
    "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"

    # Provide a polkit authentication UI.
    # This is used for example when running systemd commands without root.
    # "systemctl --user start hyprpolkitagent.service"
    # "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"

    # TODO: This is started by niri already (extract to module so niri/hyprland can both use it)
    # "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

    # TODO: This is started by niri already (extract to module so niri/hyprland can both use it)
    "dunst"
  ]
]
