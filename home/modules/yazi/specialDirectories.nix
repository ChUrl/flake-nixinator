{color}: let
  mkIcon = name: text: fg: {
    inherit name text fg;
  };
in [
  (mkIcon "Documents" "󰈙" color.hexS.accentHL)
  (mkIcon "Downloads" "󰇚" color.hexS.accentHL)
  (mkIcon "Games" "󰓓" color.hexS.accentHL)
  (mkIcon "GitRepos" "" color.hexS.accentHL)
  (mkIcon "Movies" "󰿎" color.hexS.accentHL)
  (mkIcon "Music" "󰎄" color.hexS.accentHL)
  (mkIcon "NixFlake" "" color.hexS.accentHL)
  (mkIcon "Notes" "󰠮" color.hexS.accentHL)
  (mkIcon "Pictures" "" color.hexS.accentHL)
  (mkIcon "Projects" "󱃷" color.hexS.accentHL)
  (mkIcon "Public" "󰒗" color.hexS.accentHL)
  (mkIcon "Restic" "󰁯" color.hexS.accentHL)
  (mkIcon "Shows" "󰿎" color.hexS.accentHL)
  (mkIcon "Unity" "󰚯" color.hexS.accentHL)
  (mkIcon "Videos" "" color.hexS.accentHL)
]
