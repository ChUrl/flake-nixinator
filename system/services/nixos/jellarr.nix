{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Upstream pins the pnpm dependency hash against its own nixpkgs, which makes
  # its package fail here. Rebuild it with the hash for our nixpkgs.
  # The module hardcodes that package and only uses it for ExecStart, so the
  # patched one is injected below.
  jellarr = (pkgs.callPackage "${inputs.jellarr.outPath}/nix/package.nix" {}).overrideAttrs (_: {
    pnpmDeps = pkgs.fetchPnpmDeps {
      pname = "jellarr";
      version = "0.1.0";
      src = inputs.jellarr.outPath;
      fetcherVersion = 4;
      hash = "sha256-qNVnhHjTFPhJxJ8oZPBSfJs2OjNSlbmS31okZuSGWMU=";
    };
  });
in {
  # API key created in the Jellyfin UI (Dashboard → API Keys) and stored in
  # sops; no bootstrap, so Jellyfin is never stopped to write its database.
  sops.secrets."jellarr-api-key" = {};

  sops.templates."jellarr-env".content = ''
    JELLARR_API_KEY=${config.sops.placeholder."jellarr-api-key"}
  '';

  services.jellarr = {
    enable = true;
    environmentFile = config.sops.templates."jellarr-env".path;

    # Applies only the fields listed here; everything else is left to the UI.
    config = {
      version = 1;
      base_url = "http://127.0.0.1:8096";

      # NOTE: deliberately no `encoding:` block — the jellyfin module in
      #       system/services/nixos/jellyfin.nix owns encoding.xml
      #       (forceEncodingConfig). Two writers would fight on every restart.

      startup.completeStartupWizard = true;

      # Grow this from `jellarr dump --baseUrl http://127.0.0.1:8096`:
      # system.pluginRepositories, branding, plugins, library, …
      # Leave `users:` out until the passwords/policies are in sops.
    };
  };

  systemd.services.jellarr.serviceConfig.ExecStart = lib.mkForce "${jellarr}/bin/jellarr";

  # Convenience: `jellarr dump` / manual runs need the binary on PATH.
  environment.systemPackages = [jellarr];
}
