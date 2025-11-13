{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) hyprpanel color;
in {
  options.modules.hyprpanel = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf hyprpanel.enable {
    programs.hyprpanel = {
      enable = true;
      systemd.enable = false;

      settings = {
        #
        # Bar Config
        #

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/index.ts
        "scalingPriority" = "hyprland";
        "wallpaper.enable" = false;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/index.ts
        "bar.autoHide" = "never";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/layouts/index.ts
        # TODO: To module option
        # TODO: This should contain battery etc. for laptop
        "bar.layouts" = {
          "DP-1" = {
            "left" = ["workspaces" "windowtitle"];
            "middle" = ["media"]; # "cava"
            "right" = ["volume" "network" "cpu" "ram" "storage" "clock" "systray" "notifications"]; # "bluetooth"
          };
          "DP-2" = {
            "left" = ["workspaces" "windowtitle"];
            "middle" = ["media"]; # "cava"
            "right" = ["volume" "clock" "notifications"];
          };
        };

        # TODO: Expose this as a module option: applicationIcons = {kitty = "󰄛"; ...};
        "bar.workspaces.applicationIconMap" = {
          "class:^(kitty)$" = "󰄛";
          "class:^(org\.keepassxc\.KeePassXC)$" = "󰟵";
          "class:^(com\.nextcloud\.desktopclient\.nextcloud)$" = "";
          "class:^(neovide)$" = "";
          "class:^(jetbrains-clion)$" = "";
          "class:^(jetbrains-idea)$" = "";
          "class:^(jetbrains-pycharm)$" = "";
          "class:^(jetbrains-rustrover)$" = "";
          "class:^(jetbrains-rider)$" = "";
          "class:^(jetbrains-webstorm)$" = "";
          "class:^(obsidian)$" = "";
          "class:^(anki)$" = "";
          "class:^(blender)$" = "󰂫";
          "class:^(unityhub)$" = "";
          "class:^(Unity)$" = "";
          "class:^(steam)$" = "";
          "class:^(steam_app_)(.+)$" = "";
          "class:^(signal)$" = "󱋊";
          "class:^(Spotify)$" = "";
          "class:^(rmpc)$" = "󰝚";
          "class:^(discord)$" = "";
          "class:^(Zotero)$" = "";
          "class:^(org.zealdocs.zeal)$" = "󰞋";
          "class:^(navi)$" = "";
          "class:^(org.qutebrowser.qutebrowser)$" = "󰖟";
        };

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/index.ts
        "theme.bar.background" = "#${color.hex.base}";
        "theme.bar.border.color" = "#${color.hex.accent}";
        "theme.bar.border.location" = "full";
        "theme.bar.border_radius" = "6px";
        "theme.bar.border.width" = "2px";
        "theme.bar.dropdownGap" = "50px";
        "theme.bar.floating" = true;
        "theme.bar.label_spacing" = "0px"; # what does this do?
        "theme.bar.margin_bottom" = "0px";
        "theme.bar.margin_sides" = "10px";
        "theme.bar.margin_top" = "10px";
        "theme.bar.opacity" = 75;
        "theme.bar.outer_spacing" = "0px"; # NOTE: Left/Right bar padding
        "theme.bar.transparent" = false;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/index.ts
        "theme.bar.buttons.opacity" = 100;
        "theme.bar.buttons.padding_x" = "10px";
        "theme.bar.buttons.padding_y" = "2px";
        "theme.bar.buttons.radius" = "3px";
        "theme.bar.buttons.spacing" = "2px"; # NOTE: Horizontal inter-button spacing
        "theme.bar.buttons.style" = "default";
        "theme.bar.buttons.text" = "#${color.hex.accentText}";
        "theme.bar.buttons.y_margins" = "2px"; # NOTE: Top/Bottom bar padding

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/general/index.ts
        "theme.font.label" = color.font;
        "theme.font.name" = color.font;
        "theme.font.size" = "14px";
        "theme.font.weight" = 600;

        #
        # Modules Config
        #

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/workspaces/index.ts
        "bar.workspaces.applicationIconEmptyWorkspace" = "";
        "bar.workspaces.applicationIconFallback" = "󰣆";
        "bar.workspaces.applicationIconOncePerWorkspace" = true;
        "bar.workspaces.ignored" = "-\\d+"; # Special workspaces
        "bar.workspaces.monitorSpecific" = true;
        "bar.workspaces.numbered_active_indicator" = "highlight";
        "bar.workspaces.reverse_scroll" = true;
        "bar.workspaces.show_icons" = false;
        "bar.workspaces.show_numbered" = false;
        "bar.workspaces.showAllActive" = true;
        "bar.workspaces.showApplicationIcons" = true; # requires showWsIcons
        "bar.workspaces.showWsIcons" = true;
        # "bar.workspaces.spacing" = 1;
        "bar.workspaces.workspaces" = 9;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/workspaces.ts
        "theme.bar.buttons.workspaces.active" = "#${color.hex.accentHl}";
        "theme.bar.buttons.workspaces.available" = "#${color.hex.accentText}";
        "theme.bar.buttons.workspaces.background" = "#${color.hex.accent}";
        "theme.bar.buttons.workspaces.border" = "#${color.hex.accent}";
        "theme.bar.buttons.workspaces.enableBorder" = false;
        "theme.bar.buttons.workspaces.fontSize" = "18px";
        "theme.bar.buttons.workspaces.hover" = "#${color.hex.accentHl}";
        "theme.bar.buttons.workspaces.numbered_active_highlight_border" = "4px"; # border radius
        "theme.bar.buttons.workspaces.numbered_active_highlighted_text_color" = "#${color.hex.accentText}";
        "theme.bar.buttons.workspaces.numbered_active_highlight_padding" = "6px";
        "theme.bar.buttons.workspaces.numbered_active_underline_color" = "#${color.hex.accentHl}";
        "theme.bar.buttons.workspaces.numbered_inactive_padding" = "6px"; # make the same as numbered_active_highlight_padding to avoid layout jumping
        "theme.bar.buttons.workspaces.occupied" = "#${color.hex.accentText}";
        "theme.bar.buttons.workspaces.smartHighlight" = "false";
        "theme.bar.buttons.workspaces.spacing" = "6px"; # no visible difference?

        # The pill marks the active workspace when icons are disabled
        # "theme.bar.buttons.workspaces.pill" = {
        #   "active_width" = "12em";
        #   "height" = "4em";
        #   "radius" = "4px";
        #   "width" = "4em";
        # };

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/windowtitle/index.ts
        "bar.windowtitle.class_name" = true;
        "bar.windowtitle.custom_title" = true;
        "bar.windowtitle.icon" = true;
        "bar.windowtitle.label" = true;
        "bar.windowtitle.truncation" = true;
        "bar.windowtitle.truncation_size" = 50;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/windowtitle.ts
        "theme.bar.buttons.windowtitle.background" = "#${color.hex.pink}";
        "theme.bar.buttons.windowtitle.border" = "#${color.hex.accent}";
        "theme.bar.buttons.windowtitle.enableBorder" = false;
        "theme.bar.buttons.windowtitle.icon_background" = "#${color.hex.pink}";
        "theme.bar.buttons.windowtitle.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.windowtitle.spacing" = "6px"; # Spacing between icon and text
        "theme.bar.buttons.windowtitle.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/media/index.ts
        "bar.media.format" = "{artist: - }{title}";
        "bar.media.show_active_only" = true;
        "bar.media.show_label" = true;
        "bar.media.truncation" = true;
        "bar.media.truncation_size" = 30;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/media.ts
        "theme.bar.buttons.media.background" = "#${color.hex.lavender}";
        "theme.bar.buttons.media.border" = "#${color.hex.accent}";
        "theme.bar.buttons.media.enableBorder" = false;
        "theme.bar.buttons.media.icon_background" = "#${color.hex.lavender}";
        "theme.bar.buttons.media.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.media.spacing" = "6px";
        "theme.bar.buttons.media.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/cava/index.ts
        "bar.customModules.cava.showActiveOnly" = true;
        "bar.customModules.cava.bars" = 10;
        # "bar.customModules.cava.leftClick" = "menu:media";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/cava.ts
        "theme.bar.buttons.modules.cava.background" = "#${color.hex.red}";
        "theme.bar.buttons.modules.cava.border" = "#${color.hex.accent}";
        "theme.bar.buttons.modules.cava.enableBorder" = false;
        "theme.bar.buttons.modules.cava.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.modules.cava.icon_background" = "#${color.hex.red}";
        "theme.bar.buttons.modules.cava.spacing" = "6px";
        "theme.bar.buttons.modules.cava.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/volume/index.ts
        "bar.volume.middleClick" = "kitty ncpamixer";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/volume.ts
        "theme.bar.buttons.volume.background" = "#${color.hex.maroon}";
        "theme.bar.buttons.volume.enableBorder" = false;
        "theme.bar.buttons.volume.border" = "#${color.hex.accent}";
        "theme.bar.buttons.volume.icon_background" = "#${color.hex.maroon}";
        "theme.bar.buttons.volume.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.volume.spacing" = "6px";
        "theme.bar.buttons.volume.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/network/index.ts

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/network.ts
        "theme.bar.buttons.network.background" = "#${color.hex.peach}";
        "theme.bar.buttons.network.enableBorder" = false;
        "theme.bar.buttons.network.border" = "#${color.hex.accent}";
        "theme.bar.buttons.network.icon_background" = "#${color.hex.peach}";
        "theme.bar.buttons.network.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.network.spacing" = "6px";
        "theme.bar.buttons.network.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/bluetooth/index.ts

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/bluetooth.ts
        "theme.bar.buttons.bluetooth.background" = "#${color.hex.yellow}";
        "theme.bar.buttons.bluetooth.enableBorder" = false;
        "theme.bar.buttons.bluetooth.border" = "#${color.hex.accent}";
        "theme.bar.buttons.bluetooth.icon_background" = "#${color.hex.yellow}";
        "theme.bar.buttons.bluetooth.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.bluetooth.spacing" = "6px";
        "theme.bar.buttons.bluetooth.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/cpu/index.ts
        "bar.customModules.cpu.middleClick" = "kitty btop";
        "bar.customModules.cpu.pollingInterval" = 1000;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/cpu.ts
        "theme.bar.buttons.modules.cpu.background" = "#${color.hex.green}";
        "theme.bar.buttons.modules.cpu.enableBorder" = false;
        "theme.bar.buttons.modules.cpu.border" = "#${color.hex.accent}";
        "theme.bar.buttons.modules.cpu.icon_background" = "#${color.hex.green}";
        "theme.bar.buttons.modules.cpu.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.modules.cpu.spacing" = "6px";
        "theme.bar.buttons.modules.cpu.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/ram/index.ts
        "bar.customModules.ram.labelType" = "percentage"; # "used/total", "percentage"
        "bar.customModules.ram.pollingInterval" = 1000;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/ram.ts
        "theme.bar.buttons.modules.ram.background" = "#${color.hex.teal}";
        "theme.bar.buttons.modules.ram.enableBorder" = false;
        "theme.bar.buttons.modules.ram.border" = "#${color.hex.accent}";
        "theme.bar.buttons.modules.ram.icon_background" = "#${color.hex.teal}";
        "theme.bar.buttons.modules.ram.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.modules.ram.spacing" = "6px";
        "theme.bar.buttons.modules.ram.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/storage/index.ts
        "bar.customModules.storage.labelType" = "percentage"; # "used/total", "percentage"
        "bar.customModules.storage.tooltipStyle" = "simple"; # "tree", "percentage-bar", "simple"
        "bar.customModules.storage.pollingInterval" = 60000;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/storage.ts
        "theme.bar.buttons.modules.storage.background" = "#${color.hex.sky}";
        "theme.bar.buttons.modules.storage.enableBorder" = false;
        "theme.bar.buttons.modules.storage.border" = "#${color.hex.accent}";
        "theme.bar.buttons.modules.storage.icon_background" = "#${color.hex.sky}";
        "theme.bar.buttons.modules.storage.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.modules.storage.spacing" = "6px";
        "theme.bar.buttons.modules.storage.text" = "#${color.hex.accentText}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/clock/index.ts
        "bar.clock.format" = "%Y-%m-%d %H:%M";
        "bar.clock.showTime" = true;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/clock.ts
        "theme.bar.buttons.clock.background" = "#${color.hex.sapphire}";
        "theme.bar.buttons.clock.enableBorder" = false;
        "theme.bar.buttons.clock.border" = "#${color.hex.accent}";
        "theme.bar.buttons.clock.icon_background" = "#${color.hex.sapphire}";
        "theme.bar.buttons.clock.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.clock.spacing" = "6px";
        "theme.bar.buttons.clock.text" = "#${color.hex.accentText}";

        # TODO: To module option
        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/systray/index.ts
        "bar.systray.ignore" = [
          "Fcitx" # Keyboard indicator
        ]; # Middle click the tray icon to show a notification with the app name :)
        "bar.systray.customIcons" = {};

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/systray.ts
        "theme.bar.buttons.systray.background" = "#${color.hex.blue}";
        "theme.bar.buttons.systray.enableBorder" = false;
        "theme.bar.buttons.systray.border" = "#${color.hex.accent}";
        "theme.bar.buttons.systray.customIcon" = "#${color.hex.accentText}";
        "theme.bar.buttons.systray.spacing" = "6px";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/notifications/index.ts
        "bar.notifications.hideCountWhenZero" = true;
        "bar.notifications.show_total" = true;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/notifications.ts
        "theme.bar.buttons.notifications.background" = "#${color.hex.accent}";
        "theme.bar.buttons.notifications.enableBorder" = false;
        "theme.bar.buttons.notifications.border" = "#${color.hex.accent}";
        "theme.bar.buttons.notifications.icon_background" = "#${color.hex.accent}";
        "theme.bar.buttons.notifications.icon" = "#${color.hex.accentText}";
        "theme.bar.buttons.notifications.spacing" = "6px";
        "theme.bar.buttons.notifications.total" = "#${color.hex.accentText}";

        #
        # TODO: Menus Config
        #

        "theme.bar.menus.background" = "#${color.hex.base}";
        "theme.bar.menus.border.color" = "#${color.hex.accent}";
        "theme.bar.menus.border.radius" = "6px";
        "theme.bar.menus.border.size" = "2px";
        "theme.bar.menus.buttons.radius" = "0.4em";
        "theme.bar.menus.card_radius" = "0.4em";

        "menus.clock.time.military" = true;
        "menus.clock.weather.location" = "Dortmund";
        "menus.clock.weather.key" = "1d22720b9e0848a9b1303412251706"; # Don't care if public
        "menus.clock.weather.unit" = "metric";

        "menus.transition" = "crossfade";
        "menus.transitionTime" = 200;

        #
        # TODO: Notifications Config
        #

        "notifications.position" = "top right";
        "notifications.showActionsOnHover" = true;
        "notifications.timeout" = 5000;
      };
    };
  };
}
