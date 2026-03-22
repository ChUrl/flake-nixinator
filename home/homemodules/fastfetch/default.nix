{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) fastfetch color;
in {
  options.homemodules.fastfetch = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf fastfetch.enable {
    programs.fastfetch = {
      enable = true;

      settings = {
        logo = {
          padding = {
            top = 4;
            left = 1;
            right = 2;
          };
        };

        display = {
          separator = "";
          key.width = 17;
        };

        # Box Drawing: ╭ ─ ╮ ╰ ╯ │
        modules = [
          # Title
          {
            type = "title";
            format = "{#1}╭─── {#}{user-name-colored}";
          }

          # System Information
          {
            type = "custom";
            format = "{#1}│ {#}System Information";
          }
          {
            type = "os";
            key = "{#separator}│  {#keys}󰍹 OS";
          }
          {
            type = "kernel";
            key = "{#separator}│  {#keys}󰒋 Kernel";
          }
          {
            type = "bootmgr";
            key = "{#separator}│  {#keys}󰒋 BootMGR";
          }
          {
            type = "uptime";
            key = "{#separator}│  {#keys}󰅐 Uptime";
          }
          {
            type = "packages";
            key = "{#separator}│  {#keys}󰏖 Packages";
            # format = "{all}";
          }
          {
            type = "custom";
            format = "{#1}│";
          }

          # Desktop Environment
          {
            type = "custom";
            format = "{#1}│ {#}Desktop Environment";
          }
          {
            type = "de";
            key = "{#separator}│  {#keys}󰧨 DE";
          }
          {
            type = "wm";
            key = "{#separator}│  {#keys}󱂬 WM";
          }
          {
            type = "wmtheme";
            key = "{#separator}│  {#keys}󰉼 Theme";
          }
          {
            type = "display";
            key = "{#separator}│  {#keys}󰹑 Resolution";
          }
          {
            type = "shell";
            key = "{#separator}│  {#keys}󰞷 Shell";
          }
          {
            type = "terminalfont";
            key = "{#separator}│  {#keys}󰛖 Font";
          }
          {
            type = "icons";
            key = "{#separator}│  {#keys} Icons";
          }
          {
            type = "cursor";
            key = "{#separator}│  {#keys}󰆽 Cursor";
          }
          {
            type = "custom";
            format = "{#1}│";
          }

          # Hardware Information
          {
            type = "custom";
            format = "{#1}│ {#}Hardware Information";
          }
          {
            type = "board";
            key = "{#separator}│  {#keys} Board";
          }
          {
            type = "cpu";
            key = "{#separator}│  {#keys}󰻠 CPU";
          }
          {
            type = "gpu";
            key = "{#separator}│  {#keys}󰢮 GPU";
          }
          {
            type = "memory";
            key = "{#separator}│  {#keys}󰍛 Memory";
          }
          # {
          #   type = "disk";
          #   key = "{#separator}│  {#keys}󰋊 Disk (/)";
          #   folders = "/";
          # }
          # {
          #   type = "disk";
          #   key = "{#separator}│  {#keys}󰋊 Disk (~/Games)";
          #   folders = "/home/christoph/Games";
          # }
          {
            type = "btrfs";
            key = "{#separator}│  {#keys}󰋊 BTRFS";
          }
          {
            type = "custom";
            format = "{#1}│";
          }

          # Colors Footer
          {
            type = "colors";
            key = "{#separator}╰─── {#1}";
            keyWidth = 6;
            symbol = "circle";
          }
        ];
      };
    };
  };
}
