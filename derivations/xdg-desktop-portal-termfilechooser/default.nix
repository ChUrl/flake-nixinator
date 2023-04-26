# NOTE: Adapted from nixpkgs xdg-desktop-portal-wlr derivation
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  wayland-protocols,
  wayland-scanner,
  # , grim
  inih,
  libdrm,
  mesa,
  pipewire,
  scdoc,
  # , slurp
  systemd,
  wayland,
}:
stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal-termfilechooser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "GermainZ";
    repo = pname;
    rev = "71dc7ab06751e51de392b9a7af2b50018e40e062"; # Was last commit on 17.04.2023
    sha256 = "sha256-645hoLhQNncqfLKcYCgWLbSrTRUNELh6EAdgUVq3ypM=";
  };

  # scdoc: mark as build-time dependency
  # https://github.com/emersion/xdg-desktop-portal-wlr/pull/248
  # patches = [(fetchpatch {
  #   url = "https://github.com/emersion/xdg-desktop-portal-wlr/commit/92ccd62428082ba855e359e83730c4370cd1aac7.patch";
  #   hash = "sha256-mU1whfp7BoSylaS3y+YwfABImZFOeuItSXCon0C7u20=";
  # })];

  # Add hyprland to portal metainformation
  patches = [
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/GermainZ/xdg-desktop-portal-termfilechooser/pull/6.patch";
      hash = "sha256-GjK6GL15liHYm5U0XBSIf5H8Cc4RIWBD0O47lLWcep0=";
    })
  ];

  strictDeps = true;
  depsBuildBuild = [pkg-config];
  nativeBuildInputs = [meson ninja pkg-config scdoc wayland-scanner makeWrapper];
  buildInputs = [inih libdrm mesa pipewire systemd wayland wayland-protocols];

  mesonFlags = [
    "-Dsd-bus-provider=libsystemd"
  ];

  # postInstall = ''
  #   wrapProgram $out/libexec/xdg-desktop-portal-termfilechooser --prefix PATH ":" ${lib.makeBinPath [ grim slurp ]}
  # '';

  meta = with lib; {
    homepage = "https://github.com/GermainZ/xdg-desktop-portal-termfilechooser";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
