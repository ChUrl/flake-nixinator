{
  config,
  hyprland,
  color,
}: {
  enable = true;

  settings = {
    general = {
      # DPMS - Display Powermanagement Signaling. "On" means the monitor is on.
      after_sleep_cmd = "hyprctl dispatch dpms on";
      ignore_dbus_inhibit = false;
      lock_cmd = "hyprlock";
    };

    listener = [
      {
        timeout = 900;
        on-timeout = "hyprlock";
      }
      {
        timeout = 1200;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };
}
