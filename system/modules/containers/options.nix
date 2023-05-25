# TODO: Rofi Integration
#       - Hotkey through hyprland module
#       - Menu through rofi module
#       - Permissions through polkit module
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
  stablediffusion = {
    enable = mkEnableOpt "Enable StableDiffusion Container with Automatic1111 WebUI";
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
