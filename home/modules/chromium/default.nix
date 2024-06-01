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
    home.packages = with pkgs; builtins.concatLists [
      (optionals cfg.google [
        google-chrome # Trash, but required for decker pdf export
        (pkgs.writeShellScriptBin "chrome" "exec -a $0 ${google-chrome}/bin/google-chrome-stable $@")
      ])
    ];

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
