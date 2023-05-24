# TODO: Expose some settings
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
  cfg = config.modules.chromium;
in {
  options.modules.chromium = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;

      # TODO: Extensions for ungoogled, see https://discourse.nixos.org/t/home-manager-ungoogled-chromium-with-extensions/15214
      # package = pkgs.ungoogled-chromium;

      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # UBlock Origin
        {id = "oboonakemofpalcgghocfoadofidjkkk";} # KeepassXC Browser
        {id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp";} # Privacy Badger
        {id = "lckanjgmijmafbedllaakclkaicjfmnk";} # ClearURLs
        {id = "njdfdhgcmkocbgbhcioffdbicglldapd";} # LocalCDN
        {id = "jaoafjdoijdconemdmodhbfpianehlon";} # Skip Redirect
      ];
    };
  };
}
