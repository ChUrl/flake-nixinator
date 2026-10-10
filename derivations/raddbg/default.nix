{
  lib,
  clangStdenv,
  fetchFromGitHub,
  pkg-config,
  llvm,
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

    install -Dm755 build/raddbg $out/bin/raddbg
    install -Dm755 build/raddbg_non_graphical $out/bin/raddbg_non_graphical
    install -Dm755 build/radbin $out/bin/radbin
    install -Dm755 build/radlink $out/bin/radlink

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
