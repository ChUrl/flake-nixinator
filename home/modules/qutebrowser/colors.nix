{color}: {
  webpage.darkmode.enabled = true;

  completion = {
    ## Background color of the completion widget category headers.
    category.bg = color.hexS.base;
    category.fg = color.hexS.accent;

    ## Bottom border color of the completion widget category headers.
    category.border.top = color.hexS.base;
    category.border.bottom = color.hexS.accent;

    ## Background color of the completion widget for even and odd rows.
    even.bg = color.hexS.base;
    odd.bg = color.hexS.base;

    ## Text color of the completion widget.
    fg = color.hexS.text;

    # Selected item color + border
    item.selected.bg = color.hexS.accent;
    item.selected.fg = color.hexS.accentText;
    item.selected.border.bottom = color.hexS.surface2;
    item.selected.border.top = color.hexS.surface2;

    ## Foreground color of the selected completion item.
    item.selected.match.fg = color.hexS.accentText;

    ## Foreground color of the matched text in the completion.
    match.fg = color.hexS.accent;

    ## Color of the scrollbar in completion view
    scrollbar.bg = color.hexS.base;
    scrollbar.fg = color.hexS.accent;
  };

  downloads = {
    bar.bg = color.hexS.base;

    error.bg = color.hexS.base;
    error.fg = color.hexS.red;

    # Color gradient
    start.bg = color.hexS.base;
    start.fg = color.hexS.blue;
    stop.bg = color.hexS.base;
    stop.fg = color.hexS.green;

    # Set to "none" to disable gradient, otherwise "rgb"
    system.fg = "none";
    system.bg = "none";
  };

  hints = {
    ## Background color for hints. Note that you can use a `rgba(...)` value
    ## for transparency.
    bg = color.hexS.accentDim;
    fg = color.hexS.accentText;

    ## Font color for the matched part of hints.
    match.fg = color.hexS.accent;
  };

  keyhint = {
    ## Background color of the keyhint widget.
    bg = color.hexS.accentDim;
    fg = color.hexS.accentText;

    ## Highlight color for keys to complete the current keychain.
    suffix.fg = color.hexS.accent;
  };

  messages = {
    ## Background color of an error message.
    error.bg = color.hexS.base;
    error.fg = color.hexS.red;
    error.border = color.hexS.red;

    ## Background color of an info message.
    info.bg = color.hexS.base;
    info.fg = color.hexS.blue;
    info.border = color.hexS.blue;

    ## Background color of a warning message.
    warning.bg = color.hexS.base;
    warning.fg = color.hexS.yellow;
    warning.border = color.hexS.yellow;
  };

  prompts = {
    ## Background color for prompts.
    bg = color.hexS.base;
    fg = color.hexS.text;

    # ## Border used around UI elements in prompts.
    border = "1px solid " + color.hexS.overlay0;

    ## Background color for the selected item in filename prompts.
    selected.bg = color.hexS.accent;
    selected.fg = color.hexS.accentText;
  };

  statusbar = {
    ## Background color of the statusbar.
    normal.bg = color.hexS.base;
    normal.fg = color.hexS.text;

    ## Background color of the statusbar in insert mode.
    insert.bg = color.hexS.green;
    insert.fg = color.hexS.accentText;

    ## Background color of the statusbar in command mode.
    command.bg = color.hexS.peach;
    command.fg = color.hexS.accentText;

    ## Background color of the statusbar in caret mode.
    caret.bg = color.hexS.blue;
    caret.fg = color.hexS.accentText;

    ## Background color of the statusbar in caret mode with a selection.
    caret.selection.bg = color.hexS.blue;
    caret.selection.fg = color.hexS.accentText;

    ## Background color of the progress bar.
    progress.bg = color.hexS.base;

    ## Background color of the statusbar in passthrough mode.
    passthrough.bg = color.hexS.red;
    passthrough.fg = color.hexS.accentText;

    ## Default foreground color of the URL in the statusbar.
    # NOTE: The colors will be barely legible in different modes,
    #       but currently we can't change url color per mode...
    url.fg = color.hexS.text;
    url.warn.fg = color.hexS.yellow;
    url.error.fg = color.hexS.red;
    url.hover.fg = color.hexS.sky;
    url.success.http.fg = color.hexS.red;
    url.success.https.fg = color.hexS.green;

    ## PRIVATE MODE COLORS
    ## Background color of the statusbar in private browsing mode.
    private.bg = color.hexS.teal;
    private.fg = color.hexS.accentText;

    ## Background color of the statusbar in private browsing + command mode.
    command.private.bg = color.hexS.peach;
    command.private.fg = color.hexS.accentText;
  };

  tabs = {
    ## Background color of the tab bar.
    bar.bg = color.hexS.base;

    # ## Background color of selected even tabs.
    selected.even.bg = color.hexS.accent;
    selected.even.fg = color.hexS.accentText;

    # ## Background color of selected odd tabs.
    selected.odd.bg = color.hexS.accent;
    selected.odd.fg = color.hexS.accentText;

    ## Background color of unselected even tabs.
    even.bg = color.hexS.base;
    even.fg = color.hexS.accent;

    ## Background color of unselected odd tabs.
    odd.bg = color.hexS.base;
    odd.fg = color.hexS.accent;

    ## Color for the tab indicator on errors.
    indicator.error = color.hexS.red;

    ## Color gradient interpolation system for the tab indicator.
    ## Valid values:
    ##	 - rgb: Interpolate in the RGB color system.
    ##	 - hsv: Interpolate in the HSV color system.
    ##	 - hsl: Interpolate in the HSL color system.
    ##	 - none: Don't show a gradient.
    indicator.system = "none";
  };

  contextmenu = {
    menu.bg = color.hexS.base;
    menu.fg = color.hexS.accent;

    disabled.bg = color.hexS.base;
    disabled.fg = color.hexS.text;

    selected.bg = color.hexS.accent;
    selected.fg = color.hexS.accentText;
  };
}
