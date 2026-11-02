{color}: let
  mkIcon = name: text: {
    inherit name text;
    fg = color.hexS.accentHl;
  };
in [
  # /home/christoph/
  (mkIcon "Arcane" "")
  (mkIcon "Documents" "󰈙")
  (mkIcon "Downloads" "󰇚")
  (mkIcon "Games" "󰓓")
  (mkIcon "GitRepos" "")
  (mkIcon "Movies" "󰿎")
  (mkIcon "Mount" "󰧯")
  (mkIcon "Music" "󰎄")
  (mkIcon "NixFlake" "")
  (mkIcon "Notes" "󰠮")
  (mkIcon "Pictures" "")
  (mkIcon "Projects" "󱃷")
  (mkIcon "Proxmox" "󰁯")
  (mkIcon "Public" "󰒗")
  (mkIcon "Restic" "󰁯")
  (mkIcon "Shows" "󰿎")
  (mkIcon "SSD" "󰉉")
  (mkIcon "Unity" "󰚯")
  (mkIcon "Videos" "")
]
