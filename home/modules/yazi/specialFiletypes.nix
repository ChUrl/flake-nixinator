{
  lib,
  nixosConfig,
  color,
}: let
  mkFiletype = name: fg: {
    inherit name fg;
  };

  mkFiletypes = names: fg: names |> mkFiletype fg;
in
  lib.mkMerge [
    [
      (mkFiletype "*" color.hexS.text) # Files default
      (mkFiletype "*/" color.hexS.lavender) # Directories default
      (mkFiletype "application/*zip" color.hexS.accentHL)
      (mkFiletype "application/x-(mkFiletypetarbzip*7z-compressedxzrar)" color.hexS.accentHL)
      (mkFiletype "application/pdf" color.hexS.green)
    ]

    (mkFiletypes nixosConfig.modules.mime.textTypes color.hexS.text)
    (mkFiletypes nixosConfig.modules.mime.imageTypes color.hexS.teal)
    (mkFiletypes nixosConfig.modules.mime.videoTypes color.hexS.yellow)
    (mkFiletypes nixosConfig.modules.mime.audioTypes color.hexS.sky)
  ]
