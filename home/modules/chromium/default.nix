{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) chromium;
in {
  options.modules.chromium = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf chromium.enable {
    home.packages = with pkgs;
      builtins.concatLists [
        (lib.optionals chromium.google [
          google-chrome # Trash, but required for decker pdf export

          # Required for some flatpak compatibility
          (pkgs.writeShellScriptBin "chrome" "exec -a $0 ${google-chrome}/bin/google-chrome-stable $@")
        ])
      ];

    programs.chromium = {
      enable = true;

      commandLineArgs = [
        "--ignore-gpu-blocklist"
        "--use-angle=" # Prevents chromium from spamming stdout and crashing
        "--ozone-platform=wayland"
      ];

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
