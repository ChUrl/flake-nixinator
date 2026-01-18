{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.systemmodules) mime;
in {
  options.systemmodules.mime = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf mime.enable {
    xdg = {
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
      # Find .desktop files: fd ".*\.desktop" / | grep --color=auto -E neovide
      mime = rec {
        enable = true;

        defaultApplications = let
          associations =
            {
              ${mime.defaultTextEditor} = mime.textTypes;
              ${mime.defaultFileBrowser} = ["inode/directory"];
              ${mime.defaultWebBrowser} = mime.webTypes;
              ${mime.defaultPdfViewer} = ["application/pdf"];
              ${mime.defaultImageViewer} = mime.imageTypes;

              # If audio and video player are equal, we assign all types to the audio player,
              # as multiple identical keys cannot exist in attrsets.
              ${mime.defaultAudioPlayer} =
                mime.audioTypes
                ++ (lib.optionals
                  (mime.defaultAudioPlayer == mime.defaultVideoPlayer)
                  mime.videoTypes);
            }
            # If audio and video player are not equal, we associate the video types with
            # the chosen video player. Otherwise video types will be included with audio.
            // (lib.optionalAttrs (mime.defaultAudioPlayer != mime.defaultVideoPlayer) {
              ${mime.defaultVideoPlayer} = mime.videoTypes;
            });

          # Applied to a single app and a single type
          # Result: { "image/jpg" = ["imv.desktop"]; }
          mkAssociation = app: type: {${type} = [app];};

          # Applied to a single app and a list of types
          # Result: { "image/jpg" = ["imv.desktop"]; "image/png" = ["imv.desktop"]; ... }
          mkAssociations = app: types:
            lib.mergeAttrsList
            (builtins.map (mkAssociation app) types);
        in
          # Apply to a list of apps each with a list of types
          lib.mergeAttrsList (lib.mapAttrsToList mkAssociations associations);

        addedAssociations = defaultApplications;

        removedAssociations = let
          # Applied to a list of apps and a single type
          removeAssociation = apps: type: {${type} = apps;};

          # Applied to a list of apps and a list of types:
          # For each type the list of apps should be removed
          removeAssociations = apps: types:
            lib.mergeAttrsList
            (builtins.map (removeAssociation apps) types);

          # Only create if more than 0 apps are specified: (len from...Types) > 0
          mkIfExists = apps: types:
            lib.optionalAttrs
            (builtins.lessThan 0 (builtins.length apps))
            (removeAssociations apps types);
        in
          lib.mergeAttrsList [
            {
              "application/pdf" = [
                "chromium-browser.desktop"
                "com.google.Chrome.desktop"
                "firefox.desktop"
              ];
              "text/plain" = [
                "firefox.desktop"
                "code.desktop"
              ];
            }

            (mkIfExists mime.removedTextTypes mime.textTypes)
            (mkIfExists mime.removedImageTypes mime.imageTypes)
            (mkIfExists mime.removedAudioTypes mime.audioTypes)
            (mkIfExists mime.removedVideoTypes mime.videoTypes)
            (mkIfExists mime.removedWebTypes mime.webTypes)
          ];
      };
    };
  };
}
