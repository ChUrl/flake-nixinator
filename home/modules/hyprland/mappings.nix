{
  lib,
  config,
  hyprland,
}:
lib.mergeAttrsList [
  {
    # Hyprland control
    "$mainMod, q" = ["killactive"];
    "$mainMod, v" = ["togglefloating"];
    "$mainMod, f" = ["fullscreen"];
    "$mainMod, tab" = ["workspace, previous"];
    # "$mainMod, g" = ["togglegroup"];
    # "ALT, tab" = ["changegroupactive"];

    # Move focus with mainMod + arrow keys
    "$mainMod, h" = ["movefocus, l"];
    "$mainMod, l" = ["movefocus, r"];
    "$mainMod, k" = ["movefocus, u"];
    "$mainMod, j" = ["movefocus, d"];

    # Swap windows
    "$mainMod CTRL, h" = ["movewindow, l"];
    "$mainMod CTRL, l" = ["movewindow, r"];
    "$mainMod CTRL, k" = ["movewindow, u"];
    "$mainMod CTRL, d" = ["movewindow, d"];

    # Reset workspaces to the defined configuration in hyprland.workspaces:
    "CTRL ALT, r" = let
      mkWBinding = m: w:
        "moveworkspacetomonitor, "
        + "${builtins.toString w} ${builtins.toString m}";

      mkWsBindings = m: ws: builtins.map (mkWBinding m) ws;
    in
      hyprland.workspaces
      |> builtins.mapAttrs mkWsBindings
      |> builtins.attrValues
      |> builtins.concatLists;
  }

  # Switch to WS: "$mainMod, 1" = ["workspace, 1"];
  (let
    mkWBinding = w: k: {"$mainMod, ${k}" = ["workspace, ${w}"];};
  in
    hyprland.keybindings.ws-bindings
    |> builtins.mapAttrs mkWBinding
    |> builtins.attrValues
    |> lib.mergeAttrsList)

  # Toggle special WS: "$mainMod, x" = ["togglespecialworkspace, ferdium"];
  (let
    mkSpecialWBinding = w: k: {"$mainMod, ${k}" = ["togglespecialworkspace, ${w}"];};
  in
    hyprland.keybindings.special-ws-bindings
    |> builtins.mapAttrs mkSpecialWBinding
    |> builtins.attrValues
    |> lib.mergeAttrsList)

  # Move to WS: "$mainMod SHIFT, 1" = ["movetoworkspace, 1"];
  (let
    mkMoveWBinding = w: k: {"$mainMod SHIFT, ${k}" = ["movetoworkspace, ${w}"];};
  in
    (hyprland.keybindings.ws-bindings)
    |> builtins.mapAttrs mkMoveWBinding
    |> builtins.attrValues
    |> lib.mergeAttrsList)

  # Move to special WS: "$mainMod SHIFT, x" = ["movetoworkspace, special:ferdium"];
  (let
    mkSpecialMoveWBinding = w: k: {"$mainMod SHIFT, ${k}" = ["movetoworkspace, special:${w}"];};
  in
    hyprland.keybindings.special-ws-bindings
    |> builtins.mapAttrs mkSpecialMoveWBinding
    |> builtins.attrValues
    |> lib.mergeAttrsList)
]
