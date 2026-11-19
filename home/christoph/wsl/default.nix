# Shared configuration of the WSL2 home environments (`wslix` and `wslren`).
# The non-graphical part of home/christoph/default.nix is used as-is (headless),
# so the terminal environment is the same as on the other headless hosts.
# On top of that, the WSL hosts get the graphical bits that still make sense in
# WSLg windows (kitty, neovide, fonts). Niri itself is disabled on both hosts.
{
  lib,
  ...
}: {
  home.stateVersion = "26.11";

  homemodules = {
    # Icon and cursor theme, also only installed on the non-headless hosts.
    color.installPackages = lib.mkForce true;

    # `ssh` would expand to "kitty +kitten ssh", which only works when the
    # shell actually runs inside a kitty window. The shells of the WSL hosts
    # are started from Windows Terminal, so the abbreviation is dropped.
    fish.kittySshAbbr = lib.mkForce false;

    # kitty is carried over from the nested niri session and still useful for
    # GUI programs (yazi, fastfetch, ...). Terminals are otherwise only enabled
    # on the non-headless hosts.
    kitty.enable = lib.mkForce true;

    neovim = {
      enable = lib.mkForce true;
      alias = lib.mkForce true;
      # home/homemodules/terminal defaults this to !headless.
      neovide = lib.mkForce true;
    };

    terminal.enable = lib.mkForce true;
  };

  # Enable the fontconfig setup of the user profile like on the other hosts
  # that come with a graphical session.
  fonts.fontconfig.enable = lib.mkForce true;

  # Merged into the global ssh config of homemodules/ssh.
  programs.ssh.settings = {
    "*" = {
      ServerAliveInterval = lib.mkForce 60;
      StrictHostKeyChecking = "no";
    };
  };

  # Unlike the other hosts, the ssh key is not provided by sops (the WSL hosts
  # do not use the shared secrets.yaml). Keep it at ~/.ssh/id_ed25519;
  # programs.keychain and the git commit signing from home/christoph/default.nix
  # pick it up like everywhere else. home.file.".ssh/id_ed25519{,.pub}" stay
  # disabled on this host so they don't replace it.
}
