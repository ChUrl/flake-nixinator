{color}: let
  mkExt = name: text: fg: {
    inherit name text fg;
  };
in [
  # (mkExt "nix" "" color.hexS.sky)
]
