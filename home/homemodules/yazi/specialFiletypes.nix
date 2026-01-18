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

    (mkMimes color.hexS.text nixosConfig.modules.mime.textTypes)
    (mkMimes color.hexS.teal nixosConfig.modules.mime.imageTypes)
    (mkMimes color.hexS.yellow nixosConfig.modules.mime.videoTypes)
    (mkMimes color.hexS.sky nixosConfig.modules.mime.audioTypes)
  ]
