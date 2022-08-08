{ config, lib, pkgs, ... }:

rec {
  audio = import ./audio.nix { inherit config lib pkgs; };
  emacs = import ./emacs.nix { inherit config lib pkgs; };
  flatpak = import ./flatpak.nix { inherit config lib pkgs; };
  gaming = import ./gaming.nix { inherit config lib pkgs; };
}
