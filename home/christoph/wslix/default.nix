# Host override for the WSL2 host.
# The non-graphical part of home/christoph/default.nix is used as-is (headless),
# so the terminal environment is the same as on the other headless hosts.
# On top of that, this host runs niri nested into WSLg (see system/wslix).
{lib, ...}: {
  config = {
    home.stateVersion = "26.11";

    homemodules = {
      # Icon and cursor theme used by the niri GTK/Qt config, also only
      # installed on the non-headless hosts.
      color.installPackages = lib.mkForce true;

      # kitty is what the niri key bindings, walker and the menus spawn.
      # Terminals are otherwise only enabled on the non-headless hosts.
      kitty.enable = lib.mkForce true;

      neovim = {
        enable = lib.mkForce true;
        alias = lib.mkForce true;
        # home/homemodules/terminal defaults this to !headless.
        neovide = lib.mkForce true;
      };

      terminal.enable = lib.mkForce true;

      waybar = {
        enable = lib.mkForce true;
        monitors = ["winit"];
      };
    };

    # Enable the fontconfig setup of the user profile like on the other hosts
    # that come with a graphical session.
    fonts.fontconfig.enable = lib.mkForce true;

    programs.niri.settings = {
      # Nested inside WSLg there is exactly one output and it is called
      # "winit", so the DP-1/DP-2 layout of the desktop does not apply.
      # Note that niri swaps Mod to Alt in nested mode, because Super (Win)
      # stays with the Windows desktop.
      outputs = lib.mkForce {
        "winit" = {
          focus-at-startup = true;
        };
      };

      # The workspaces of the desktop are pinned to its two monitors; here niri
      # should just manage them dynamically.
      workspaces = lib.mkForce {};

      # The desktop also starts fcitx5 and nextcloud, which are not installed
      # on this host.
      spawn-at-startup = lib.mkForce [
        {argv = ["waypaper" "--restore"];}
        {argv = ["kitty" "--hold" "fastfetch"];}
      ];
    };

    # Unlike the other hosts, the ssh key is not provided by sops (this host has
    # no age key). Keep it at ~/.ssh/id_ed25519; programs.keychain and the git
    # commit signing from home/christoph/default.nix pick it up like everywhere
    # else. home.file.".ssh/id_ed25519{,.pub}" stay disabled on this host so
    # they don't replace it.
  };
}
