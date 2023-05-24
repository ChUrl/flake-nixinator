# TODO: Generate the config modularly, like with hyprland
#       - It should especially be possible to set styling programatically, for themes
{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.waybar;
  hypr = config.modules.hyprland;
in {
  options.modules.waybar = import ./options.nix {inherit lib mylib;};

  config = let
    # Taken from https://github.com/Ruixi-rebirth/flakes/blob/main/modules/programs/wayland/waybar/workspace-patch.nix
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    workspaces-patch = pkgs.writeTextFile {
      name = "waybar-hyprctl.diff";
      text = ''
        diff --git a/src/modules/wlr/workspace_manager.cpp b/src/modules/wlr/workspace_manager.cpp
        index 6a496e6..a689be0 100644
        --- a/src/modules/wlr/workspace_manager.cpp
        +++ b/src/modules/wlr/workspace_manager.cpp
        @@ -511,7 +511,9 @@ auto Workspace::handle_clicked(GdkEventButton *bt) -> bool {
           if (action.empty())
             return true;
           else if (action == "activate") {
        -    zext_workspace_handle_v1_activate(workspace_handle_);
        +    // zext_workspace_handle_v1_activate(workspace_handle_);
        +    const std::string command = "${hyprctl} dispatch workspace " + name_;
        +    system(command.c_str());
           } else if (action == "close") {
             zext_workspace_handle_v1_remove(workspace_handle_);
           } else {
      '';
    };

    waybar-hyprland = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      patches = (oldAttrs.patches or []) ++ [workspaces-patch];
    });
  in
    mkIf cfg.enable {
      programs.waybar = {
        enable = true;
        package = waybar-hyprland;

        systemd = {
          enable = false; # Gets started by hyprland
        };
      };

      modules.hyprland.autostart = let
        waybar-reload = pkgs.writeScript "waybar-reload" ''
          #! ${pkgs.bash}/bin/bash

          trap "${pkgs.procps}/bin/pkill waybar" EXIT

          while true; do
              ${waybar-hyprland}/bin/waybar -c $HOME/NixFlake/config/waybar/config -s $HOME/NixFlake/config/waybar/style.css &
              ${pkgs.inotifyTools}/bin/inotifywait -e create,modify $HOME/NixFlake/config/waybar/config $HOME/NixFlake/config/waybar/style.css
              ${pkgs.procps}/bin/pkill waybar
          done
        '';
      in [
        "${waybar-reload}"
      ];
    };
}
