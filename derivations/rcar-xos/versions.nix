# Hashes come from the *_archiver.SHA512 files next to the archives on Artifactory:
#   https://artifactory.global.renesas.com/artifactory/rcar-release/release/xos4/v<version>/...
# Convert with: nix hash convert --hash-algo sha512 --to sri <hex>
#
# To add a version, copy a block, change the key and replace the four hashes.
{
  "4.39.0" = {
    # Poky release shipped in this version, selects cmake/toolchain_poky_<x>_<y>.cmake
    pokyVersion = "6.0";
    sdk1 = "sha512-CxWo6geucZtUuCvFsWdRsGKSBVV8fI+m9x5xxescM0lNXlXHn1N2jblDqQExRUuKUIESLLQh8hxRKD5XiaO8LQ==";
    sdk3 = "sha512-jrsMZBS2DQIFGc0KLxu/UXOtljwuoasTB3dHs4hsj+1nTc4k6tiz5yuVS2i7upmUtMyb5dFDbcT1VNOkLCbfWg==";
    bsp = "sha512-vODOGsc8z1kSsRQB55mriAVcg6Lc88DIWx1iQagh/HFyMNiP4FD7APg8yqdGHdTYUSNEKa9NXaCnTHI+CcIcSQ==";
    poky = "sha512-3z2f7w8jmddlcSTdkD6JAhm4W44860shlCNEhyZ/19kGk9PUez13aQ/cZg1G0dQf1jPchpzLzthMlwQkIFVUEQ==";
  };
  "4.40.0" = {
    # Poky release shipped in this version, selects cmake/toolchain_poky_<x>_<y>.cmake
    pokyVersion = "6.0";
    sdk1 = "sha512-NbbAIXKjbMF0kOyhynjRoXZTDBlEAdMYJB9cEZsuZjYYiLpQbNfqOCC8EeDYIobKizHempVrnXH8pZPQbwMeIQ==";
    sdk3 = "sha512-kU3GgQKpN7LwlaO98jVVILPXMXtyULx80szzCQvMbP+iMyNtI8BosRHC+Ywh1bVSl2GNRzvCl01gprojwYJwbQ==";
    bsp = "sha512-IK1ylVtfBDv/WmHmSd55Ox8xgKH6fLRf3iusHkWUi0xa5cT51BZLLG/YyPndhc8WmocrgR7keYDYR087+F9+vA==";
    poky = "sha512-yKQ8qTYDBKlNdb4R0u5Lyr2dwspkdKu4JfUsloWvy1+Uu7NDgT8qhMtoMSlDXjt5rBs6ObC+s3KB9tC+tLbS4g==";
  };
}
