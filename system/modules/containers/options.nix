{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Enable OCI Containers";

  homeassistant = {
    enable = mkEnableOpt "Enable HomeAssistant Container";
  };
  jellyfin = {
    enable = mkEnableOpt "Enable Jellyfin Container";
  };
  fileflows = {
    enable = mkEnableOpt "Enable FileFlows Container";
  };
  sonarr = {
    enable = mkEnableOpt "Enable Sonarr Container";
  };
  radarr = {
    enable = mkEnableOpt "Enable Radarr Container";
  };
  hydra = {
    enable = mkEnableOpt "Enable Hydra Container";
  };
  sabnzbd = {
    enable = mkEnableOpt "Enable SabNzbd Container";
  };

  # TODO: I need to set the keys through the hyprland module
  #       and generate the menu through the rofi module
  rofiIntegration = {
    enable = mkEnableOpt "Enable Rofi Menu for Container Servicing";
    hotkey = mkOption {
      type = types.str;
      example = ''
        "$mainMod, D"
      '';
      default = "$mainMod, D";
      description = "What Key should trigger the Menu";
    };
  };
}
