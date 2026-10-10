{
  lib,
  clangStdenv,
  fetchFromGitHub,
  pkg-config,
  llvm,
  makeWrapper,
  freetype,
  libX11,
  libXext,
  libXfixes,
  libXrandr,
  libGL,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "raddbg";
  version = "unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "EpicGames";
    repo = "raddebugger";
    rev = "b6d8c3fd9eaf7b55960d80738365742a8fba9e29";
    hash = "sha256-rBGvDwYTX+s7ArSxBBeEWbGLF031OaOfubK8+KUl+xU=";
  };

  nativeBuildInputs = [
    pkg-config
    llvm
    makeWrapper
  ];

  buildInputs = [
    freetype
    libX11
    libXext
    libXfixes
    libXrandr
    libGL
  ];

  # metagen generates code back into the (read-only) source tree.
  postUnpack = ''
    chmod -R u+w .
  '';

  env.AR = "${llvm}/bin/llvm-ar";

  buildPhase = ''
    runHook preBuild

    bash ./build.sh raddbg radbin radlink raddbg_non_graphical release clang

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # raddbg shells out to `llvm-symbolizer` for crash callstack reports, and
    # derives the module path it feeds it from argv[0]; point argv[0] at the
    # real ELF (not this wrapper) so the symbolizer accepts it.
    #
    # EGL_PLATFORM=x11: raddbg is an X11 (Xlib/XWayland) application, but with
    # WAYLAND_DISPLAY set, libglvnd auto-selects the NVIDIA EGL Wayland platform
    # and segfaults in libnvidia-egl-wayland. Force the X11 EGL platform.
    for exe in raddbg raddbg_non_graphical radbin radlink; do
      install -Dm755 build/$exe $out/bin/$exe
      wrapProgram $out/bin/$exe \
        --argv0 "$out/bin/.''${exe}-wrapped" \
        --prefix PATH : ${lib.getBin llvm}/bin \
        --set EGL_PLATFORM x11
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "RAD Debugger - native, user-mode, multi-process graphical debugger (Linux port)";
    homepage = "https://github.com/EpicGames/raddebugger";
    changelog = "https://github.com/EpicGames/raddebugger/blob/master/CHANGELOG.md";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
    sourceProvenance = with sourceTypes; [fromSource];
  };
})
