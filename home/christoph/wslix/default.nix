# Host override for the WSL2 host.
# The non-graphical part of home/christoph/default.nix is used as-is (headless),
# so the terminal environment is the same as on the other headless hosts. Only
# the sops-managed pieces have to be turned off: this host has no age key and
# therefore no decrypted secrets.
{
  lib,
  ...
}: {
  config = {
    home.stateVersion = "26.11";

    # The sops private key is not installed on this host (see system/wslix), so
    # there is nothing to sign commits with. Generate a key locally with
    # "ssh-keygen" and/or use the Windows ssh-agent instead.
    homemodules.git.signCommits = lib.mkForce false;

    # Nothing for keychain to unlock without ~/.ssh/id_ed25519 from sops.
    programs.keychain.enable = lib.mkForce false;
  };
}
