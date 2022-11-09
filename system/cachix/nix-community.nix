
{
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      # "https://app.cachix.org/cache/nixos-rocm"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "nixos-rocm.cachix.org-1:VEpsf7pRIijjd8csKjFNBGzkBqOmw8H9PRmgAq14LnE="
    ];
  };
}
