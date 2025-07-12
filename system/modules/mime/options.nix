{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "TEMPLATE";

  defaultTextEditor = lib.mkOption {
    type = lib.types.str;
    description = "Default application to open text files";
    example = ''
      "neovide.desktop"
    '';
    default = "neovide.desktop";
  };

  defaultFileBrowser = lib.mkOption {
    type = lib.types.str;
    description = "Default application for file browsing";
    example = ''
      "yazi.desktop"
    '';
    default = "yazi.desktop";
  };

  defaultWebBrowser = lib.mkOption {
    type = lib.types.str;
    description = "Default web browser";
    example = ''
      "firefox.desktop"
    '';
    default = "firefox.desktop";
  };

  defaultPdfViewer = lib.mkOption {
    type = lib.types.str;
    description = "Default application to open PDF files";
    example = ''
      "org.pwmt.zathura.desktop"
    '';
    default = "org.pwmt.zathura.desktop";
  };

  defaultImageViewer = lib.mkOption {
    type = lib.types.str;
    description = "Default application to open image files";
    example = ''
      "imv-dir.desktop"
    '';
    default = "imv-dir.desktop";
  };

  defaultAudioPlayer = lib.mkOption {
    type = lib.types.str;
    description = "Default application to play audio files";
    example = ''
      "vlc.desktop"
    '';
    default = "vlc.desktop";
  };

  defaultVideoPlayer = lib.mkOption {
    type = lib.types.str;
    description = "Default application to play video files";
    example = ''
      "vlc.desktop"
    '';
    default = "vlc.desktop";
  };

  textTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Mime types that should be associated with a text editor";
    example = ''
      [
        "text/css"
        "text/csv"
        "text/javascript"
        "text/plain"
        "text/xml"
        "application/json"
        "application/ld+json"
        "application/x-sh"
        "application/xml"
      ]
    '';
    default = [
      "text/css"
      "text/csv"
      "text/javascript"
      "text/plain"
      "text/xml"
      "application/json"
      "application/ld+json"
      "application/x-sh"
      "application/xml"
    ];
  };

  imageTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Mime types that should be associated with an image viewer";
    example = ''
      [
        "image/apng"
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
      ]
    '';
    default = [
      "image/apng"
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/webp"
    ];
  };

  audioTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Mime types that should be associated with an audio player";
    example = ''
      [
        "audio/aac"
        "audio/flac"
        "audio/mp4"
        "audio/mpeg"
        "audio/ogg"
        "audio/opus"
        "audio/wav"
        "audio/webm"
        "audio/3gpp"
        "audio/3gpp2"
      ]
    '';
    default = [
      "audio/aac"
      "audio/flac"
      "audio/mp4"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/3gpp"
      "audio/3gpp2"
    ];
  };

  videoTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Mime types that should be associated with a video player";
    example = ''
      [
        "video/x-msvideo"
        "video/mp4"
        "video/mpeg"
        "video/ogg"
        "video/mp2t"
        "video/webm"
        "video/3gpp"
        "video/3gpp2"
      ]
    '';
    default = [
      "video/x-msvideo"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/mp2t"
      "video/webm"
      "video/3gpp"
      "video/3gpp2"
    ];
  };

  webTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Mime types that should be associated with a web browser";
    example = ''
      [
        "text/uri-list"
        "text/x-uri"
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/https"
      ]
    '';
    default = [
      "text/uri-list"
      "text/x-uri"
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/https"
    ];
  };

  removedTextTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Applications that shouldn't be used to open text files";
    example = ''
      [
        "nvim.desktop"
      ]
    '';
    default = [
      "nvim.desktop"
    ];
  };

  removedImageTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Applications that shouldn't be used to view image files";
    example = ''
      [
        "imv.desktop"
        "org.inkscape.Inkscape.desktop"
        "chromium-browser.desktop"
        "org.kde.krita.desktop"
        "krita.desktop"
        "krita_svg.desktop"
        "krita_raw.desktop"
        "krita_heif.desktop"
        "krita_webp.desktop"
        "krita_gif.desktop"
        "krita_brush.desktop"
        "krita_xcf.desktop"
        "krita_jpeg.desktop"
        "krita_spriter.desktop"
        "krita_jxl.desktop"
        "krita_ora.desktop"
        "krita_csv.desktop"
        "krita_tga.desktop"
        "krita_psd.desktop"
        "krita_png.desktop"
        "krita_tiff.desktop"
        "krita_exr.desktop"
        "krita_qimageio.desktop"
        "krita_pdf.desktop"
        "krita_jp2.desktop"
        "krita_heightmap.desktop"
        "krita_kra.desktop"
        "krita_krz.desktop"
      ]
    '';
    default = [
      "imv.desktop"
      "chromium-browser.desktop"
      "org.kde.krita.desktop"
      "krita.desktop"
      "krita_svg.desktop"
      "krita_raw.desktop"
      "krita_heif.desktop"
      "krita_webp.desktop"
      "krita_gif.desktop"
      "krita_brush.desktop"
      "krita_xcf.desktop"
      "krita_jpeg.desktop"
      "krita_spriter.desktop"
      "krita_jxl.desktop"
      "krita_ora.desktop"
      "krita_csv.desktop"
      "krita_tga.desktop"
      "krita_psd.desktop"
      "krita_png.desktop"
      "krita_tiff.desktop"
      "krita_exr.desktop"
      "krita_qimageio.desktop"
      "krita_pdf.desktop"
      "krita_jp2.desktop"
      "krita_heightmap.desktop"
      "krita_kra.desktop"
      "krita_krz.desktop"
    ];
  };

  removedAudioTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Applications that shouldn't be used to play audio files";
    example = ''
      [
        "mpv.desktop"
      ]
    '';
    default = [
      "mpv.desktop"
    ];
  };

  removedVideoTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Applications that shouldn't be used to play video files";
    example = ''
      [
        "mpv.desktop"
      ]
    '';
    default = [
      "mpv.desktop"
    ];
  };

  removedWebTypes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Web browsers that shouldn't be used for web types";
    example = ''
      [
        "chromium-browser.desktop"
        "com.google.Chrome.desktop"
      ]
    '';
    default = [
      "chromium-browser.desktop"
      "com.google.Chrome.desktop"
    ];
  };
}
