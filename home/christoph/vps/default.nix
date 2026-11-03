{
  lib,
  pkgs,
  ...
}: {
  config = {
    home.stateVersion = "26.11";

    # Because the home/default.nix turns some modules on, we have to force them off here:
    homemodules = {
      btop.enable = lib.mkForce false;
      docs.enable = lib.mkForce false;
      fastfetch.enable = lib.mkForce false;
      jellyfin-tui.enable = lib.mkForce false;
      kitty.enable = lib.mkForce false;
      lazygit.enable = lib.mkForce false;
      packages.enable = lib.mkForce false;
      neovim = {
        enable = lib.mkForce false;
        alias = lib.mkForce false;
      };
      yazi.enable = lib.mkForce false;
    };

    home.packages = with pkgs; [
      git
      htop
      tmux
      neovim
      yazi
    ];
  };
}
