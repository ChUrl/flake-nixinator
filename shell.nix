{pkgs, ...}:
# TODO: Use pkgs.mkShell or Navi for this...
pkgs.devshell.mkShell {
  name = "NixFlake Shell";

  packages = with pkgs; [];

  commands = [
    {
      name = "list-system-packages";
      help = "List currently installed system packages";
      command = "bat /etc/current-system-packages";
    }
    {
      name = "list-user-packages";
      help = "List currently installed user packages";
      command = "bat ~/.local/share/current-user-packages";
    }
    {
      name = "list-data-dirs";
      help = "List XDG_DATA_DIRS in a readable format";
      command = ''echo $XDG_DATA_DIRS | sed "s/:/\n/g" | sort -u'';
    }

    {
      name = "store-optimise";
      help = "Run NixOS store optimization (slow)";
      command = "nix-store --optimise -vv";
    }
    {
      name = "store-verify";
      help = "Run NixOS store verification with repair (slow)";
      command = "nix-store --verify --check-contents";
    }
    {
      name = "help-store-path";
      help = "Display the location of a binary in the nix store";
      command = "echo 'readlink -f (which <arg>)'";
    }
    {
      name = "help-libraries";
      help = "Display the wanted dynamic libraries by a binary";
      command = "echo 'ldd (readlink -f (which <arg>))'";
    }
    {
      name = "help-closure";
      help = "Display the closure of a package";
      command = "echo 'nix path-info --recursive --size --closure-size --human-readable (readlink -f (which <arg>))'";
    }
    {
      name = "help-disko";
      help = "Partition disk using disko";
      command = ''echo "sudo nix run 'github:nix-community/disko/latest#disko-install' -- --flake .#<target> --disk <disk-name> <disk-device>"'';
    }
  ];
}
