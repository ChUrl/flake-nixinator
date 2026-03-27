{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Receives attrs like:
  # {
  #   "Poweroff" = "poweroff";
  #   "Reload Hyprland" = "hyprctl reload";
  # }
  # mkSimpleMenu = let
  #   # Makes a string like ''"Poweroff" "Reload Hyprland"''
  #   unpack-options = attrs: "\"${lib.concatStringsSep "\" \"" (builtins.attrNames attrs)}\"";
  #
  #   mkCase = option: action: "else if test \"${option}\" = $OPTION\n    set ACTION \"${action}\"";
  #
  #   cases = attrs:
  #     attrs
  #     |> builtins.mapAttrs mkCase
  #     |> builtins.attrValues
  #     |> builtins.concatStringsSep "\n";
  # in
  #   {
  #     prompt,
  #     attrs,
  #     command ? ''rofi -dmenu -i'',
  #   }:
  #     pkgs.writeScriptBin "rofi-menu-${prompt}" ''
  #       #! ${pkgs.fish}/bin/fish
  #
  #       # OPTIONS contains all possible values Rofi will display
  #       set OPTIONS ${unpack-options attrs}
  #
  #       # We choose a single OPTION using Rofi
  #       set OPTION (echo -e (string join "\n" $OPTIONS) | ${command} -p "${prompt}")
  #
  #       # Check if the chosen OPTION is a valid choice from OPTIONS
  #       if not contains $OPTION $OPTIONS
  #           exit
  #       end
  #
  #       # Set a command to execute based on the chosen OPTION
  #       if false
  #           exit # Easier to generate with this
  #       ${cases attrs}
  #       else
  #           exit
  #       end
  #
  #       # Execute the command
  #       eval $ACTION
  #     '';

  # Rofi/Dmenu menu generator.
  #
  # Each element in `layers` is one of:
  #   - attrset { "Label" = "value"; } # static options: selected value → $OPTIONn
  #   - string  "shell-cmd"            # dynamic options from command: selected text → $OPTIONn
  #                                    # may reference $OPTION0, $OPTION1, ... from earlier layers
  #
  # The "command" is the last action, it can reference $OPTION0, $OPTION1, ...
  # If no "command" is given and the last layer is a static attrset, its selected value is evaluated directly.
  #
  # The "prompts" list are optional per-layer prompt strings (falls back to "prompt" if not provided).
  #
  # vpn.fish equivalent:
  #   mkMenu {
  #     prompt = "vpn";
  #     layers = [
  #       "cat /etc/rofi-vpns"
  #       { "start" = "start"; "stop" = "stop"; "status" = "status"; }
  #     ];
  #     command = "systemctl $OPTION1 $OPTION0.service";
  #   }
  #
  # lectures.fish equivalent:
  #   mkMenu {
  #     prompt = "lecture";
  #     layers = [
  #       "eza -1 -D ~/Notes/TU"
  #       "eza -1 ~/Notes/TU/$OPTION0/Lecture | grep '.pdf'"
  #     ];
  #     command = "xdg-open ~/Notes/TU/$OPTION0/Lecture/$OPTION1";
  #   }
  mkMenu = {
    prompt,
    layers,
    prompts ? [],
    command ? null,
    rofiCmd ? "rofi -dmenu -i",
  }: let
    isStaticLayer = layer: builtins.isAttrs layer && !(layer ? options);
    isDynamicLayer = layer: builtins.isString layer;

    escStr = s: builtins.replaceStrings [''"'' "\\"] [''\"'' "\\\\"] s;

    layerPrompt = i:
      if i < builtins.length prompts
      then lib.elemAt prompts i
      else prompt;

    # Static layer: attrset of label -> value
    # Displays labels in rofi; maps selected label to its value -> $OPTIONi
    mkStaticLayer = i: attrs: let
      lp = layerPrompt i;
      labels = builtins.attrNames attrs;
      optsStr = "\"${lib.concatStringsSep "\" \"" (map escStr labels)}\"";
      mkCase = label: value: "else if test \"${escStr label}\" = $_LABEL${toString i}\n    set OPTION${toString i} \"${escStr value}\"";
      casesStr =
        builtins.concatStringsSep "\n"
        (builtins.attrValues (builtins.mapAttrs mkCase attrs));
    in {
      script = ''
        set _OPTS${toString i} ${optsStr}
        set _LABEL${toString i} (echo -e (string join "\n" $_OPTS${toString i}) | ${rofiCmd} -p "${lp}")
        if not contains $_LABEL${toString i} $_OPTS${toString i}
            exit
        end
        if false
            exit
        ${casesStr}
        else
            exit
        end
      '';
    };

    # Dynamic layer: shell command string whose output is piped to rofi
    # Selected text -> $OPTIONi; may reference earlier $OPTIONn variables
    mkDynamicLayer = i: cmd: let
      lp = layerPrompt i;
    in {
      script = ''
        set OPTION${toString i} (${cmd} | ${rofiCmd} -p "${lp}")
        if test -z $OPTION${toString i}
            exit
        end
      '';
    };

    mkLayer = i: layer:
      if isStaticLayer layer
      then mkStaticLayer i layer
      else if isDynamicLayer layer
      then mkDynamicLayer i layer
      else throw "mkMenu: layer ${toString i} has invalid type";

    layerResults = lib.imap0 mkLayer layers; # Map with 0-based index
    layerScripts = map (r: r.script) layerResults;
    lastLayer = lib.last layers;

    finalCmd =
      if command != null
      then command
      else if isStaticLayer lastLayer
      then "$OPTION${toString (builtins.length layers - 1)}"
      else throw "mkMenu: 'command' must be set when the last layer is not a static attrset";
  in
    pkgs.writeScriptBin "rofi-menu-${prompt}" ''
      #! ${pkgs.fish}/bin/fish

      ${lib.concatStringsSep "\n" layerScripts}
      eval "${finalCmd}"
    '';
}
