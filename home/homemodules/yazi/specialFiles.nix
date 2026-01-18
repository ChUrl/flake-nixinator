{color}: let
  mkFile = name: text: fg: {
    inherit name text fg;
  };
in [
  # (mkFile "flake.lock" "" color.hexS.sky)
]
