{
  lib,
  nixosConfig,
  color,
}: let
  mkName = fg: name: {
    inherit name fg;
  };

  mkMime = fg: mime: {
    inherit mime fg;
  };

  mkMimes = fg: mimes: mimes |> builtins.map (mkMime fg);
in
  builtins.concatLists [
    [
      (mkName color.hexS.text "*") # Files default
      (mkName color.hexS.lavender "*/") # Directories default
      (mkMime color.hexS.green "application/pdf")
    ]

    (mkMimes color.hexS.text nixosconfig.homemodules.mime.textTypes)
    (mkMimes color.hexS.teal nixosconfig.homemodules.mime.imageTypes)
    (mkMimes color.hexS.yellow nixosconfig.homemodules.mime.videoTypes)
    (mkMimes color.hexS.sky nixosconfig.homemodules.mime.audioTypes)
  ]
