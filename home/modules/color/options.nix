{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  scheme = mkOption {
    type = types.str;
    description = "The color scheme to use";
    example = "catppuccin-latte";
  };
}
