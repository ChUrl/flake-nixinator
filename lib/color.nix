{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # This code was blatantly stolen from here:
  # https://github.com/Misterio77/nix-colors/blob/b92df8f5eb1fa20d8e09810c03c9dc0d94ef2820/lib/core/conversions.nix#L87
  hexToDecMap = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };

  pow = base: exponent: let
    inherit (lib) mod;
  in
    if exponent > 1
    then let
      x = pow base (exponent / 2);
      odd_exp = mod exponent 2 == 1;
    in
      x
      * x
      * (
        if odd_exp
        then base
        else 1
      )
    else if exponent == 1
    then base
    else if exponent == 0 && base == 0
    then throw "undefined"
    else if exponent == 0
    then 1
    else throw "undefined";

  base16To10 = exponent: scalar: scalar * (pow 16 exponent);

  hexCharToDec = hex: let
    inherit (lib) toLower;
    lowerHex = toLower hex;
  in
    if builtins.stringLength hex != 1
    then throw "Function only accepts a single character."
    else if hexToDecMap ? ${lowerHex}
    then hexToDecMap."${lowerHex}"
    else throw "Character ${hex} is not a hexadecimal value.";
in rec {
  /*
  Converts from hexadecimal to decimal.

    Type: hexToDec :: string -> int

    Args:
      hex: A hexadecimal string.

    Example:
      hexadecimal "12"
      => 18
      hexadecimal "FF"
      => 255
      hexadecimal "abcdef"
      => 11259375
  */
  hexToDec = hex: let
    inherit (lib) stringToCharacters reverseList imap0 foldl;
    decimals = builtins.map hexCharToDec (stringToCharacters hex);
    decimalsAscending = reverseList decimals;
    decimalsPowered = imap0 base16To10 decimalsAscending;
  in
    foldl builtins.add 0 decimalsPowered;

  /*
  Converts a 6 character hexadecimal string to RGB values.

  Type: hexToRGB :: string => [int]

  Args:
    hex: A hexadecimal string of length 6.

  Example:
    hexToRGB "012345"
    => [ 1 35 69 ]
    hexToRGB "abcdef"
    => [171 205 239 ]
    hexToRGB "000FFF"
    => [ 0 15 255 ]
  */
  hexToRGB = hex: let
    rgbStartIndex = [0 2 4];
    hexList = builtins.map (x: builtins.substring x 2 hex) rgbStartIndex;
    hexLength = builtins.stringLength hex;
  in
    if hexLength != 6
    then
      throw ''
        Unsupported hex string length of ${builtins.toString hexLength}.
        Length must be exactly 6.
      ''
    else builtins.map hexToDec hexList;

  /*
  Converts a 6 character hexadecimal string to an RGB string seperated by a
  delimiter.

  Type: hexToRGBString :: string -> string

  Args:
    sep: The delimiter or seperator.
    hex: A hexadecimal string of length 6.
  */
  hexToRGBString = sep: hex: let
    inherit (builtins) map toString;
    inherit (lib) concatStringsSep;
    hexInRGB = hexToRGB hex;
    hexInRGBString = map toString hexInRGB;
  in
    concatStringsSep sep hexInRGBString;
}
