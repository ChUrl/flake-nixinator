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
      overwrite.enable = true;
      systemd.enable = true;

      # settings = {};

      # NOTE: Because the HM module sucks (mixes explicit options + JSON conversion), write everything as override...
      # HACK: Only override fully qualified quoted attributes to not override existing attrs with empty values
      #       https://github.com/Jas-SinghFSU/HyprPanel/issues/886
      override = {
        #
        # Bar Config
        #

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/index.ts
        "scalingPriority" = "hyprland";
        "wallpaper.enable" = false;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/index.ts
        "bar.autoHide" = "never";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/layouts/index.ts
        # TODO: This should contain battery etc. for laptop
        "bar.layouts" = {
          "HDMI-A-1" = {
            "left" = ["workspaces" "windowtitle"];
            "middle" = ["media" "cava"];
            "right" = ["volume" "network" "bluetooth" "cpu" "ram" "storage" "clock" "systray" "notifications"];
          };
          "DP-1" = {
            "left" = ["workspaces" "windowtitle"];
            "middle" = ["media" "cava"];
            "right" = ["volume" "clock" "notifications"];
          };
        };

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/index.ts
        "theme.bar.background" = "#${color.hex.light.base}";
        "theme.bar.border.color" = "#${color.hex.dark.lavender}";
        "theme.bar.border.location" = "full";
        "theme.bar.border_radius" = "6px";
        "theme.bar.border.width" = "2px";
        "theme.bar.dropdownGap" = "50px";
        "theme.bar.floating" = true;
        "theme.bar.margin_bottom" = "0px";
        "theme.bar.margin_sides" = "10px";
        "theme.bar.margin_top" = "10px";
        "theme.bar.opacity" = 30;
        "theme.bar.outer_spacing" = "2px";
        "theme.bar.transparent" = false;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/index.ts
        "theme.bar.buttons.opacity" = 100;
        "theme.bar.buttons.padding_x" = "10px";
        "theme.bar.buttons.padding_y" = "2px";
        "theme.bar.buttons.radius" = "6px";
        "theme.bar.buttons.separator.color" = "#ff7800";
        "theme.bar.buttons.spacing" = "3px";
        "theme.bar.buttons.style" = "default";
        "theme.bar.buttons.text" = "#${color.hex.dark.base}";

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
        "theme.bar.buttons.workspaces.active" = "#${color.hex.dark.pink}";
        "theme.bar.buttons.workspaces.available" = "#${color.hex.dark.base}";
        "theme.bar.buttons.workspaces.background" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.workspaces.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.workspaces.enableBorder" = false;
        "theme.bar.buttons.workspaces.fontSize" = "18px";
        "theme.bar.buttons.workspaces.hover" = "#${color.hex.dark.pink}";
        "theme.bar.buttons.workspaces.numbered_active_highlight_border" = "4px"; # border radius
        "theme.bar.buttons.workspaces.numbered_active_highlighted_text_color" = "#${color.hex.dark.base}";
        "theme.bar.buttons.workspaces.numbered_active_highlight_padding" = "6px";
        "theme.bar.buttons.workspaces.numbered_active_underline_color" = "#${color.hex.dark.pink}";
        "theme.bar.buttons.workspaces.numbered_inactive_padding" = "6px"; # make the same as numbered_active_highlight_padding to avoid layout jumping
        "theme.bar.buttons.workspaces.occupied" = "#${color.hex.dark.base}";
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
        "theme.bar.buttons.windowtitle.background" = "#${color.hex.dark.pink}";
        "theme.bar.buttons.windowtitle.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.windowtitle.enableBorder" = false;
        "theme.bar.buttons.windowtitle.icon_background" = "#${color.hex.dark.pink}";
        "theme.bar.buttons.windowtitle.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.windowtitle.spacing" = "6px"; # Spacing between icon and text
        "theme.bar.buttons.windowtitle.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/media/index.ts
        "bar.media.format" = "{artist: - }{title}";
        "bar.media.show_active_only" = true;
        "bar.media.show_label" = true;
        "bar.media.truncation" = true;
        "bar.media.truncation_size" = 30;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/media.ts
        "theme.bar.buttons.media.background" = "#${color.hex.dark.mauve}";
        "theme.bar.buttons.media.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.media.enableBorder" = false;
        "theme.bar.buttons.media.icon_background" = "#${color.hex.dark.base}";
        "theme.bar.buttons.media.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.media.spacing" = "6px";
        "theme.bar.buttons.media.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/cava/index.ts
        "bar.customModules.cava.showActiveOnly" = true;
        "bar.customModules.cava.bars" = 10;
        "bar.customModules.cava.leftClick" = "menu:media";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/cava.ts
        "theme.bar.buttons.modules.cava.background" = "#${color.hex.dark.red}";
        "theme.bar.buttons.modules.cava.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.modules.cava.enableBorder" = false;
        "theme.bar.buttons.modules.cava.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.modules.cava.icon_background" = "#${color.hex.dark.red}";
        "theme.bar.buttons.modules.cava.spacing" = "6px";
        "theme.bar.buttons.modules.cava.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/volume/index.ts
        "bar.volume.middleClick" = "kitty ncpamixer";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/volume.ts
        "theme.bar.buttons.volume.background" = "#${color.hex.dark.maroon}";
        "theme.bar.buttons.volume.enableBorder" = false;
        "theme.bar.buttons.volume.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.volume.icon_background" = "#${color.hex.dark.maroon}";
        "theme.bar.buttons.volume.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.volume.spacing" = "6px";
        "theme.bar.buttons.volume.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/network/index.ts

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/network.ts
        "theme.bar.buttons.network.background" = "#${color.hex.dark.peach}";
        "theme.bar.buttons.network.enableBorder" = false;
        "theme.bar.buttons.network.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.network.icon_background" = "#${color.hex.dark.peach}";
        "theme.bar.buttons.network.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.network.spacing" = "6px";
        "theme.bar.buttons.network.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/bluetooth/index.ts

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/bluetooth.ts
        "theme.bar.buttons.bluetooth.background" = "#${color.hex.dark.yellow}";
        "theme.bar.buttons.bluetooth.enableBorder" = false;
        "theme.bar.buttons.bluetooth.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.bluetooth.icon_background" = "#${color.hex.dark.yellow}";
        "theme.bar.buttons.bluetooth.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.bluetooth.spacing" = "6px";
        "theme.bar.buttons.bluetooth.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/cpu/index.ts
        "bar.customModules.cpu.middleClick" = "kitty btop";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/cpu.ts
        "theme.bar.buttons.modules.cpu.background" = "#${color.hex.dark.green}";
        "theme.bar.buttons.modules.cpu.enableBorder" = false;
        "theme.bar.buttons.modules.cpu.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.modules.cpu.icon_background" = "#${color.hex.dark.green}";
        "theme.bar.buttons.modules.cpu.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.modules.cpu.spacing" = "6px";
        "theme.bar.buttons.modules.cpu.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/ram/index.ts
        "bar.customModules.ram.labelType" = "used/total";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/ram.ts
        "theme.bar.buttons.modules.ram.background" = "#${color.hex.dark.teal}";
        "theme.bar.buttons.modules.ram.enableBorder" = false;
        "theme.bar.buttons.modules.ram.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.modules.ram.icon_background" = "#${color.hex.dark.teal}";
        "theme.bar.buttons.modules.ram.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.modules.ram.spacing" = "6px";
        "theme.bar.buttons.modules.ram.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/storage/index.ts
        "bar.customModules.storage.labelType" = "used/total";
        "bar.customModules.storage.tooltipStyle" = "tree";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/storage.ts
        "theme.bar.buttons.modules.storage.background" = "#${color.hex.dark.sky}";
        "theme.bar.buttons.modules.storage.enableBorder" = false;
        "theme.bar.buttons.modules.storage.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.modules.storage.icon_background" = "#${color.hex.dark.sky}";
        "theme.bar.buttons.modules.storage.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.modules.storage.spacing" = "6px";
        "theme.bar.buttons.modules.storage.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/clock/index.ts
        "bar.clock.format" = "%Y-%m-%d %H:%M";
        "bar.clock.showTime" = true;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/clock.ts
        "theme.bar.buttons.clock.background" = "#${color.hex.dark.sapphire}";
        "theme.bar.buttons.clock.enableBorder" = false;
        "theme.bar.buttons.clock.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.clock.icon_background" = "#${color.hex.dark.sapphire}";
        "theme.bar.buttons.clock.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.clock.spacing" = "6px";
        "theme.bar.buttons.clock.text" = "#${color.hex.dark.base}";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/systray/index.ts

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/systray.ts
        "theme.bar.buttons.systray.background" = "#${color.hex.dark.blue}";
        "theme.bar.buttons.systray.enableBorder" = false;
        "theme.bar.buttons.systray.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.systray.customIcon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.systray.spacing" = "6px";

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/config/bar/notifications/index.ts
        "bar.notifications.hideCountWhenZero" = true;
        "bar.notifications.show_total" = true;

        # https://github.com/Jas-SinghFSU/HyprPanel/blob/master/src/configuration/modules/theme/bar/buttons/notifications.ts
        "theme.bar.buttons.notifications.background" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.notifications.enableBorder" = false;
        "theme.bar.buttons.notifications.border" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.notifications.icon_background" = "#${color.hex.dark.lavender}";
        "theme.bar.buttons.notifications.icon" = "#${color.hex.dark.base}";
        "theme.bar.buttons.notifications.spacing" = "6px";
        "theme.bar.buttons.notifications.total" = "#${color.hex.dark.base}";

        #
        # TODO: Menus Config
        #

        "theme.bar.menus.background" = "#${color.hex.light.base}";
        "theme.bar.menus.border.color" = "#${color.hex.dark.lavender}";
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
