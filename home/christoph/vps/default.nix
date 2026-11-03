{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    home.stateVersion = "26.11";

    # Because the home/default.nix turns some modules on, we have to force them off here:
    homemodules = {
      docs.enable = lib.mkForce false;
      lazygit.enable = lib.mkForce false;
      neovim = {
        enable = lib.mkForce false;
        alias = lib.mkForce false;
      };
      packages.enable = lib.mkForce false;
      terminal.enable = true;
      yazi.enable = lib.mkForce false;
    };

    home = {
      packages = with pkgs; [
        atool
        dig
        duf
        file
        gdu
        git
        htop
        neovim
        ouch
        p7zip
        sd
        systemctl-tui
        tmux
        unrar
        unzip
        wget
        yazi
      ];
    };

    programs = {
      eza = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      fd.enable = true;

      fzf = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      navi = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      zoxide = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };
    };
  };
}
