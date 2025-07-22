{
  config,
  headless,
}: {
  enable = !headless;
  dunst.enable = !config.modules.hyprpanel.enable; # Disable for hyprpanel
  bars.enable = false;
  dynamicCursor.enable = true;
  trails.enable = true;
  hyprspace.enable = true;

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
      "kitty"
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

  windowrules = [];

  workspacerules = {
    "1" = [];
    "2" = ["Zotero" "neovide" "code-url-handler"];
    "3" = ["obsidian" "unityhub" "Unity"];
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
