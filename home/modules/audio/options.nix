{
  lib,
  mylib,
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Audio module";

  # TODO: Group these in categories (like instruments/VSTs or sth)
  # TODO: Make it easier to add many yes/no options, similar to the flatpak stuff

  # Hosts/Editing
  carla.enable = mkEnableOpt "Carla (VST host)";
  bitwig.enable = mkEnableOpt "Bitwig (Digital audio workstation)";
  tenacity.enable = mkEnableOpt "Tenacity (Audacity fork)";

  # Instruments/Plugins
  # vcvrack.enable = mkEnableOpt "VCV-Rack (Eurorack simulator)"; # Replaced by cardinal
  cardinal.enable = mkEnableOpt "Open Source VCV-Rack plugin wrapper";
  # vital.enable = mkEnableOpt "Vital (Wavetable synthesizer)"; # Replaced by distrho
  distrho.enable = mkEnableOpt "Distrho (Linux VST ports)";

  # Misc
  faust.enable = mkEnableOpt "Faust (functional DSP language)";
  bottles.enable = mkEnableOpt "Bottles (flatpak)";

  # TODO: Automatically add the needed paths, depends on the bottle though
  # /home/christoph/.var/app/com.usebottles.bottles/data/bottles/bottles/Audio/drive_c/Program Files/Common Files/VST3
  # /home/christoph/.var/app/com.usebottles.bottles/data/bottles/bottles/Audio/drive_c/Program Files/VstPlugins
  yabridge = {
    enable = mkEnableOpt "Yabridge (Windows VST plugin manager)";
    autoSync = mkBoolOpt false "Sync yabridge plugins on nixos-rebuild";
  };

  noisesuppression = {
    noisetorch = {
      enable = mkEnableOpt "Noisetorch";
      autostart = mkBoolOpt false "Autoload Noisetorch suppression";
    };

    # TODO: Store easyeffects presets/config (dconf com/github/wwmm/easyeffects ?)
    easyeffects = {
      enable = mkEnableOpt "EasyEffects";
      autostart = mkBoolOpt false "Autoload EasyEffects suppression profile";
    };
  };
}
