# https://github.com/davatorium/rofi/blob/next/doc/rofi-theme.5.markdown#basic-layout-structure
# https://github.com/davatorium/rofi/blob/next/doc/rofi-theme.5.markdown#base-widgets
{
  color,
  mkLiteral,
}: let
  trans = "rgba(0, 0, 0, 0)";
in {
  "element-text,element-icon,mode-switcher" = {
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  "window" = {
    height = mkLiteral "50%";
    width = mkLiteral "33%";
    border = mkLiteral "2 solid 2 solid 2 solid 2 solid";
    border-radius = 6;
    border-color = mkLiteral color.hexS.accent;

    # This is not opacity but translucency
    background-color = mkLiteral "rgba(${color.rgbS.base}, 0.25)";
  };

  "mainbox" = {
    background-color = mkLiteral trans;
  };

  # TOP INPUT BAR START

  "inputbar" = {
    children = builtins.map mkLiteral ["prompt" "entry"];
    background-color = mkLiteral trans;
  };

  "prompt" = {
    background-color = mkLiteral color.hexS.accentHl;
    padding = 6;
    text-color = mkLiteral color.hexS.accentText;
    border-radius = 3;
    margin = mkLiteral "10px 0px 0px 10px";
  };

  "entry" = {
    padding = 6;
    margin = mkLiteral "10px 10px 0px 5px";
    text-color = mkLiteral color.hexS.text;
    background-color = mkLiteral trans;
    border = mkLiteral "2 solid 2 solid 2 solid 2 solid";
    border-radius = 3;
    border-color = mkLiteral color.hexS.accentHl;
  };

  # MESSAGEBOX (usually not visible)

  "message" = {
    background-color = mkLiteral trans;
  };

  "error-message" = {
    background-color = mkLiteral trans;
    margin = mkLiteral "0px 0px 10px 0px";
  };

  "textbox" = {
    background-color = mkLiteral trans;
    padding = 6;
    margin = mkLiteral "10px 10px 0px 10px";
    border-radius = 3;
  };

  # LISTVIEW

  "listview" = {
    # border = mkLiteral "0px 0px 0px";
    padding = 0;
    margin = mkLiteral "5px 10px 10px 10px";
    columns = 1;
    background-color = mkLiteral trans;
    border = mkLiteral "2 solid 2 solid 2 solid 2 solid";
    border-radius = 3;
    border-color = mkLiteral color.hexS.accentDim;
  };

  "element" = {
    padding = 5;
    margin = 0;
    background-color = mkLiteral trans;
    text-color = mkLiteral color.hexS.text;
    # border-radius = 3;
  };

  "element-icon" = {
    size = 25;
  };

  "element selected" = {
    background-color = mkLiteral color.hexS.accentDim;
    text-color = mkLiteral color.hexS.accentText;
  };
}
