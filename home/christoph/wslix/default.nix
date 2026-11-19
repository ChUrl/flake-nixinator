# Host override for the WSL2 host of the home machine.
# Everything shared with wslren lives in home/christoph/wsl; this host has no
# home-manager additions of its own. The shared ssh hosts of homemodules/ssh
# (nixinator, servenix, thinknix, ...) stay enabled here.
{
  imports = [../wsl];
}
