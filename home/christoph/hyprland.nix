{
  pkgs,
  config,
  headless,
}: {
  enable = !headless;
  dunst.enable = !config.modules.hyprpanel.enable; # Disable for hyprpanel
  bars.enable = false;
  dynamicCursor.enable = false;
  trails.enable = true;
  hyprspace.enable = false; # Always broken

  keybindings = {
    main-mod = "SUPER";

    bindings = {
      "$mainMod, t" = ["exec, kitty"];
      "$mainMod, e" = ["exec, kitty --title=Yazi yazi"];
      "$mainMod, n" = ["exec, neovide"];
      # "$mainMod, r" = ["exec, kitty --title=Rmpc rmpc"];
      "$mainMod CTRL, n" = ["exec, kitty --title=Navi navi"];
      "$mainMod SHIFT, n" = ["exec, neovide ${config.paths.dotfiles}/navi/christoph.cheat"];
      "$mainMod SHIFT, f" = ["exec, neovide ${config.paths.dotfiles}/flake.nix"];

      "$mainMod, p" = ["exec, hyprpicker --autocopy --format=hex"];
      "$mainMod, s" = ["exec, grim -g \"$(slurp)\""];
      "$mainMod CTRL, s" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];
      "$mainMod SHIFT, s" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];

      ", XF86AudioRaiseVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"];
      ", XF86AudioLowerVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"];
      ", XF86AudioPlay" = ["exec, playerctl play-pause"];
      ", XF86AudioPrev" = ["exec, playerctl previous"];
      ", XF86AudioNext" = ["exec, playerctl next"];

      ", XF86MonBrightnessDown" = ["exec, hyprctl hyprsunset gamma -10"];
      ", XF86MonBrightnessUp" = ["exec, hyprctl hyprsunset gamma +10"];
      "$mainMod, XF86MonBrightnessDown" = ["exec, hyprctl hyprsunset temperature 5750"];
      "$mainMod, XF86MonBrightnessUp" = ["exec, hyprctl hyprsunset identity"];

      "CTRL ALT, f" = let
        hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
        grep = "${pkgs.gnugrep}/bin/grep";
        awk = "${pkgs.gawk}/bin/gawk";
        notify = "${pkgs.libnotify}/bin/notify-send";

        toggleMouseFocus = pkgs.writeScriptBin "hypr-toggle-mouse-focus" ''
          CURRENT=$(${hyprctl} getoption input:follow_mouse | ${grep} int | ${awk} -F' ' '{print $2}')

          if [[ "$CURRENT" == "1" ]]; then
            ${hyprctl} keyword input:follow_mouse 0
            ${notify} "Disabled Mouse Focus!"
          else
            ${hyprctl} keyword input:follow_mouse 1
            ${notify} "Enabled Mouse Focus!"
          fi
        '';
      in ["exec, ${toggleMouseFocus}/bin/hypr-toggle-mouse-focus"];

      # "CTRL ALT, t" = ["exec, bash -c 'systemctl --user restart hyprpanel.service'"];
    };

    ws-bindings = {
      # "<Workspace>" = "<Key>";
      "1" = "1";
      "2" = "2";
      "3" = "3";
      "4" = "4";
      "5" = "5";
      "6" = "6";
      "7" = "7";
      "8" = "8";
      "9" = "9";
      "10" = "0";
    };

    special-ws-bindings = {
      "ferdium" = "x";
      "msty" = "z";
      "btop" = "b";
      "rmpc" = "r";
    };
  };

  autostart = {
    immediate = [
      "kitty --hold fastfetch"
      "zeal"
      "nextcloud --background"
      "protonvpn-app"

      # "kdeconnect-indicator" # started by services.kdeconnect.indicator
    ];

    delayed = [
      "keepassxc" # The tray doesn't work when started too early
    ];

    special-silent = {
      "ferdium" = ["ferdium"];
      "msty" = ["msty"];
      "btop" = ["kitty --title=Btop btop"];
      "rmpc" = ["kitty --title=Rmpc rmpc"];
    };
  };

  windowrules = [
    # Fix jetbrains tooltip flicker
    "float,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
    "nofocus,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
  ];

  workspacerules = {
    "1" = [];
    "2" = ["Zotero" "neovide" "code-url-handler"];
    "3" = ["obsidian"];
    "4" = ["firefox" "Google-chrome" "chromium-browser" "org.qutebrowser.qutebrowser"];
    "5" = ["steam"];
    "6" = ["steam_app_(.+)"];
    "7" = ["signal"];
    "8" = ["tidal-hifi"];
    "9" = ["discord"];
    "10" = ["python3"];
  };

  floating = [
    {class = "org.kde.polkit-kde-authentication-agent-1";}
    {
      class = "thunar";
      title = "File Operation Progress";
    }
    {class = "ffplay";}
    {class = "Unity";}
  ];

  transparent-opacity = "0.75";

  transparent = [
    "kitty"
    "Alacritty"
    "discord"
    "signal"
    "vesktop"
    "Spotify"
    "tidal-hifi"
    "obsidian"
    "firefox"
    "org.qutebrowser.qutebrowser"
    "jetbrains-clion"
    "jetbrains-idea"
    "jetbrains-pycharm"
    "jetbrains-rustrover"
    "jetbrains-rider"
    "jetbrains-webstorm"
    "code-url-handler"
    "neovide"
    "steam"
    "ferdium"
    "Msty"
  ];
}
