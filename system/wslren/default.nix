# NixOS-WSL host of the work machine (Intel integrated graphics, no NVIDIA).
# Everything shared with wslix lives in system/wsl; this host adds the Renesas
# toolchain access (R-Car xOS, QNX) and its own secrets file.
{
  config,
  username,
  ...
}: {
  imports = [../wsl];

  # The Windows machine points mesa at its Intel integrated adapter.
  environment.sessionVariables.MESA_D3D12_DEFAULT_ADAPTER_NAME = "Intel";

  # Secrets of this host only, see system/wsl for the age setup. The password
  # hash is installed before the user is created, which makes sudo ask for it.
  sops = {
    secrets."user-password" = {
      sopsFile = ./secrets.yaml;
      neededForUsers = true;
    };

    secrets."adms61-mcp-token" = {
      sopsFile = ./secrets.yaml;
      owner = username;
    };

    # Artifactory access token for rcar-xos-fetch (derivations/rcar-xos-fetch)
    secrets."artifactory-token" = {
      sopsFile = ./secrets.yaml;
      owner = username;
    };

    # The same token as netrc for the nix-daemon, so builtin:fetchurl can
    # download the R-Car xOS archives (derivations/rcar-xos). Artifactory takes
    # the access token as basic-auth password, the login is the token subject.
    templates."nix-netrc".content = ''
      machine artifactory.global.renesas.com
        login christoph.urlacher.yf@renesas.com
        password ${config.sops.placeholder."artifactory-token"}
    '';
  };

  nix.settings.netrc-file = config.sops.templates."nix-netrc".path;
}
