{color}: {
  completion = {
    ## Background color of the completion widget category headers.
    category.bg = color.hexS.base;

    ## Bottom border color of the completion widget category headers.
    category.border.bottom = color.hexS.mantle;

    ## Top border color of the completion widget category headers.
    category.border.top = color.hexS.overlay2;

    ## Foreground color of completion widget category headers.
    category.fg = color.hexS.green;

    ## Background color of the completion widget for even and odd rows.
    even.bg = color.hexS.mantle;
    odd.bg = color.hexS.mantle;

    ## Text color of the completion widget.
    fg = color.hexS.subtext0;

    ## Background color of the selected completion item.
    item.selected.bg = color.hexS.surface2;

    ## Bottom border color of the selected completion item.
    item.selected.border.bottom = color.hexS.surface2;

    ## Top border color of the completion widget category headers.
    item.selected.border.top = color.hexS.surface2;

    ## Foreground color of the selected completion item.
    item.selected.fg = color.hexS.text;

    ## Foreground color of the selected completion item.
    item.selected.match.fg = color.hexS.rosewater;

    ## Foreground color of the matched text in the completion.
    match.fg = color.hexS.text;

    ## Color of the scrollbar in completion view
    scrollbar.bg = color.hexS.crust;

    ## Color of the scrollbar handle in completion view.
    scrollbar.fg = color.hexS.surface2;
  };

  downloads = {
    bar.bg = color.hexS.base;
    error.bg = color.hexS.base;
    start.bg = color.hexS.base;
    stop.bg = color.hexS.base;

    error.fg = color.hexS.red;
    start.fg = color.hexS.blue;
    stop.fg = color.hexS.green;
    system.fg = "none";
    system.bg = "none";
  };

  hints = {
    ## Background color for hints. Note that you can use a `rgba(...)` value
    ## for transparency.
    bg = color.hexS.peach;

    ## Font color for hints.
    fg = color.hexS.mantle;

    ## Hints
    border = "1px solid " + color.hexS.mantle;

    ## Font color for the matched part of hints.
    match.fg = color.hexS.subtext1;
  };

  keyhint = {
    ## Background color of the keyhint widget.
    bg = color.hexS.mantle;

    ## Text color for the keyhint widget.
    fg = color.hexS.text;

    ## Highlight color for keys to complete the current keychain.
    suffix.fg = color.hexS.subtext1;
  };

  messages = {
    ## Background color of an error message.
    error.bg = color.hexS.overlay0;

    ## Background color of an info message.
    info.bg = color.hexS.overlay0;

    ## Background color of a warning message.
    warning.bg = color.hexS.overlay0;

    ## Border color of an error message.
    error.border = color.hexS.mantle;

    ## Border color of an info message.
    info.border = color.hexS.mantle;

    ## Border color of a warning message.
    warning.border = color.hexS.mantle;

    ## Foreground color of an error message.
    error.fg = color.hexS.red;

    ## Foreground color an info message.
    info.fg = color.hexS.text;

    ## Foreground color a warning message.
    warning.fg = color.hexS.peach;
  };

  prompts = {
    ## Background color for prompts.
    bg = color.hexS.mantle;

    # ## Border used around UI elements in prompts.
    border = "1px solid " + color.hexS.overlay0;

    ## Foreground color for prompts.
    fg = color.hexS.text;

    ## Background color for the selected item in filename prompts.
    selected.bg = color.hexS.surface2;

    ## Background color for the selected item in filename prompts.
    selected.fg = color.hexS.rosewater;
  };

  statusbar = {
    ## Background color of the statusbar.
    normal.bg = color.hexS.base;

    ## Background color of the statusbar in insert mode.
    insert.bg = color.hexS.crust;

    ## Background color of the statusbar in command mode.
    command.bg = color.hexS.base;

    ## Background color of the statusbar in caret mode.
    caret.bg = color.hexS.base;

    ## Background color of the statusbar in caret mode with a selection.
    caret.selection.bg = color.hexS.base;

    ## Background color of the progress bar.
    progress.bg = color.hexS.base;

    ## Background color of the statusbar in passthrough mode.
    passthrough.bg = color.hexS.base;

    ## Foreground color of the statusbar.
    normal.fg = color.hexS.text;

    ## Foreground color of the statusbar in insert mode.
    insert.fg = color.hexS.rosewater;

    ## Foreground color of the statusbar in command mode.
    command.fg = color.hexS.text;

    ## Foreground color of the statusbar in passthrough mode.
    passthrough.fg = color.hexS.peach;

    ## Foreground color of the statusbar in caret mode.
    caret.fg = color.hexS.peach;

    ## Foreground color of the statusbar in caret mode with a selection.
    caret.selection.fg = color.hexS.peach;

    ## Foreground color of the URL in the statusbar on error.
    url.error.fg = color.hexS.red;

    ## Default foreground color of the URL in the statusbar.
    url.fg = color.hexS.text;

    ## Foreground color of the URL in the statusbar for hovered links.
    url.hover.fg = color.hexS.sky;

    ## Foreground color of the URL in the statusbar on successful load
    url.success.http.fg = color.hexS.teal;

    ## Foreground color of the URL in the statusbar on successful load
    url.success.https.fg = color.hexS.green;

    ## Foreground color of the URL in the statusbar when there's a warning.
    url.warn.fg = color.hexS.yellow;

    ## PRIVATE MODE COLORS
    ## Background color of the statusbar in private browsing mode.
    private.bg = color.hexS.mantle;

    ## Foreground color of the statusbar in private browsing mode.
    private.fg = color.hexS.subtext1;

    ## Background color of the statusbar in private browsing + command mode.
    command.private.bg = color.hexS.base;

    ## Foreground color of the statusbar in private browsing + command mode.
    command.private.fg = color.hexS.subtext1;
  };

  tabs = {
    ## Background color of the tab bar.
    bar.bg = color.hexS.crust;

    ## Background color of unselected even tabs.
    even.bg = color.hexS.surface2;

    ## Background color of unselected odd tabs.
    odd.bg = color.hexS.surface1;

    ## Foreground color of unselected even tabs.
    even.fg = color.hexS.overlay2;

    ## Foreground color of unselected odd tabs.
    odd.fg = color.hexS.overlay2;

    ## Color for the tab indicator on errors.
    indicator.error = color.hexS.red;

    ## Color gradient interpolation system for the tab indicator.
    ## Valid values:
    ##	 - rgb: Interpolate in the RGB color system.
    ##	 - hsv: Interpolate in the HSV color system.
    ##	 - hsl: Interpolate in the HSL color system.
    ##	 - none: Don't show a gradient.
    indicator.system = "none";

    # ## Background color of selected even tabs.
    selected.even.bg = color.hexS.base;

    # ## Background color of selected odd tabs.
    selected.odd.bg = color.hexS.base;

    # ## Foreground color of selected even tabs.
    selected.even.fg = color.hexS.text;

    # ## Foreground color of selected odd tabs.
    selected.odd.fg = color.hexS.text;
  };

  contextmenu = {
    menu.bg = color.hexS.base;
    menu.fg = color.hexS.text;

    disabled.bg = color.hexS.mantle;
    disabled.fg = color.hexS.overlay0;

    selected.bg = color.hexS.overlay0;
    selected.fg = color.hexS.rosewater;
  };
}
