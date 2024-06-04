{mylib, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../modules
  ];

  modules = {
    systemd-networkd = {
      wireguard-tunnels = {
        wg0-de-74 =
          mylib.networking.mkWireguardService
          "wg0-de-74"
          "proton-de-74.key"
          "fvHmPj3wAKolN80+/KJ3a/DFjMToCsr3iPGwX8+og1g="
          "194.126.177.7";

        wg0-lu-6 =
          mylib.networking.mkWireguardService
          "wg0-lu-6"
          "proton-lu-6.key"
          "EAZS8FTE2sXm8NFD8ViqcO5PMzvnyIHD1ScxX8UxIzE="
          "92.223.89.141";
      };
    };
  };

  programs.light.enable = true;

  services.xserver = {
    # Configure keymap in X11
    xkb.layout = "de";
    xkb.variant = "nodeadkeys";

    # Proprietary graphics drivers
    videoDrivers = ["intel"];
  };
}
