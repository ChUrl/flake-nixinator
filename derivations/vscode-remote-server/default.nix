{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "remote-server";
    publisher = "ms-vscode";
    version = "1.6.2026092109";
    hash = "sha256-K0iBnI3y7P5Qi8UI0lF0DIzIFczaexr6pohTDUvCexo=";
  };

  meta = {
    description = "Remote - Tunnels: connect to a VS Code Server via a dev tunnel";
    license = lib.licenses.unfree;
  };
}
