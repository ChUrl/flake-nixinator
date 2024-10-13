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
  enable = mkEnableOption "Enable OCI Containers";

  homeassistant = {
    enable = mkEnableOption "Enable HomeAssistant Container";
  };
  stablediffusion = {
    enable = mkEnableOption "Enable StableDiffusion Container with Automatic1111 WebUI";
  };
  jellyfin = {
    enable = mkEnableOption "Enable Jellyfin Container";
  };
  fileflows = {
    enable = mkEnableOption "Enable FileFlows Container";
  };
  sonarr = {
    enable = mkEnableOption "Enable Sonarr Container";
  };
  radarr = {
    enable = mkEnableOption "Enable Radarr Container";
  };
  hydra = {
    enable = mkEnableOption "Enable Hydra Container";
  };
  sabnzbd = {
    enable = mkEnableOption "Enable SabNzbd Container";
  };

  rofiIntegration = {
    enable = mkEnableOption "Enable Rofi Menu for Container Servicing";
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
