final: prev: {
  zathuraPkgs = prev.zathuraPkgs.overrideScope (inner: prevScope: {
    zathura_core = prevScope.zathura_core.overrideAttrs (old: {
      mesonFlags =
        (old.mesonFlags or [])
        ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
          "-Dtests-x11=disabled"
          "-Dtests-wayland=disabled"
        ];
    });
  });
}
