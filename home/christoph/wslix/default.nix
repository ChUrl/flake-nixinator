# Host override for the WSL2 host.
# The non-graphical part of home/christoph/default.nix is used as-is (headless),
# so the terminal environment is the same as on the other headless hosts.
{
  ...
}: {
  config = {
    home.stateVersion = "26.11";

    # Unlike the other hosts, the ssh key is not provided by sops (this host has
    # no age key). Keep it at ~/.ssh/id_ed25519; programs.keychain and the git
    # commit signing from home/christoph/default.nix pick it up like everywhere
    # else. home.file.".ssh/id_ed25519{,.pub}" stay disabled on this host so
    # they don't replace it.
  };
}
