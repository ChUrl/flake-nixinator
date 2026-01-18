{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Audio module";

  # TODO: Group these in categories (like instruments/VSTs or sth)
  # TODO: Make it easier to add many yes/no options, similar to the flatpak stuff

  # Hosts/Editing
  carla.enable = mkEnableOption "Carla (VST host)";
  bitwig.enable = mkEnableOption "Bitwig (Digital audio workstation)";
  tenacity.enable = mkEnableOption "Tenacity (Audacity fork)";

  # Instruments/Plugins
  # vcvrack.enable = mkEnableOption "VCV-Rack (Eurorack simulator)"; # Replaced by cardinal
  cardinal.enable = mkEnableOption "Open Source VCV-Rack plugin wrapper";
  # vital.enable = mkEnableOption "Vital (Wavetable synthesizer)"; # Replaced by distrho
  distrho.enable = mkEnableOption "Distrho (Linux VST ports)";

  # Misc
  faust.enable = mkEnableOption "Faust (functional DSP language)";
  bottles.enable = mkEnableOption "Bottles (flatpak)";

  # TODO: Automatically add the needed paths, depends on the bottle though
  # /home/christoph/.var/app/com.usebottles.bottles/data/bottles/bottles/Audio/drive_c/Program Files/Common Files/VST3
  # /home/christoph/.var/app/com.usebottles.bottles/data/bottles/bottles/Audio/drive_c/Program Files/VstPlugins
  yabridge = {
    enable = mkEnableOption "Yabridge (Windows VST plugin manager)";
    autoSync = mkBoolOption false "Sync yabridge plugins on nixos-rebuild";
  };

  noisesuppression = {
    noisetorch = {
      enable = mkEnableOption "Noisetorch";
      autostart = mkBoolOption false "Autoload Noisetorch suppression";
    };

    # TODO: Store easyeffects presets/config (dconf com/github/wwmm/easyeffects ?)
    easyeffects = {
      enable = mkEnableOption "EasyEffects";
      autostart = mkBoolOption false "Autoload EasyEffects suppression profile";
    };
  };
}
