{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) rmpc color;
in {
  options.modules.rmpc = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf rmpc.enable {
    assertions = [
      {
        assertion = config.services.mpd.enable;
        message = "Enabling rmpc requires mpd!";
      }
    ];

    programs.rmpc.enable = true;

    home.packages = with pkgs; [
      cava
      python313Packages.syncedlyrics
    ];

    home.file = let
      themeName = "chriphost";
    in {
      # TODO: notify-send song title or sth.
      # TODO: status bar colors (the thing that pops up in the progress/seeking bar sometimes)
      ".config/rmpc/config.ron".text = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]
        (
            address: "127.0.0.1:${builtins.toString config.services.mpd.network.port}",
            password: None,
            theme: "${themeName}",
            cache_dir: None,
            on_song_change: None,
            volume_step: 5,
            max_fps: 30,
            scrolloff: 0,
            wrap_navigation: false,
            enable_mouse: true,
            enable_config_hot_reload: true,
            status_update_interval_ms: 1000,
            rewind_to_start_sec: 30,
            lyrics_dir: "${config.home.homeDirectory}/Music/.lyrics",

            // Keep this on false, otherwise queue changes will be applied to the current playlist
            reflect_changes_to_playlist: false,

            select_current_song_on_change: false,
            browser_song_sort: [Disc, Track, Artist, Title],
            directories_sort: SortFormat(group_by_type: true, reverse: false),
            album_art: (
                method: Auto,
                max_size_px: (width: 1200, height: 1200),
                disabled_protocols: ["http://", "https://"],
                vertical_align: Center,
                horizontal_align: Center,
            ),

            search: (
                case_sensitive: false,
                mode: Contains,
                tags: [
                    (value: "any",         label: "Any Tag"),
                    (value: "artist",      label: "Artist"),
                    (value: "album",       label: "Album"),
                    (value: "albumartist", label: "Album Artist"),
                    (value: "title",       label: "Title"),
                    (value: "filename",    label: "Filename"),
                    (value: "genre",       label: "Genre"),
                ],
            ),

            artists: (
                album_display_mode: SplitByDate,
                album_sort_by: Date,
            ),

            tabs: [
                (
                    name: "Queue (1)",
                    pane: Split(
                        borders: "NONE",
                        direction: Horizontal,
                        panes: [
                            // Left Column (Queue + Cava)
                            (
                                size: "70%",
                                borders: "NONE",
                                pane: Split(
                                    direction: Vertical,
                                    panes: [
                                        (
                                            size: "75%",
                                            borders: "ALL",
                                            pane: Pane(Queue),
                                        ),
                                        (
                                            size: "25%",
                                            borders: "ALL",
                                            pane: Pane(Cava),
                                        )
                                    ]
                                )
                            ),

                            // Right Column (AlbumArt + Lyrics)
                            (
                                size: "30%",
                                borders: "NONE",
                                pane: Split(
                                    direction: Vertical,
                                    panes: [
                                        (
                                            size: "75%",
                                            borders: "ALL",
                                            pane: Pane(AlbumArt),
                                        ),
                                        (
                                            size: "25%",
                                            borders: "ALL",
                                            pane: Pane(Lyrics),
                                        ),
                                    ]
                                ),
                            ),
                        ]
                    ),
                ),
                (
                    name: "Albums (2)",
                    pane: Pane(Albums),
                ),
                (
                    name: "Album Artists (3)",
                    pane: Pane(AlbumArtists),
                ),
                (
                    name: "Artists (4)",
                    pane: Pane(Artists),
                ),
                (
                    name: "Playlists (5)",
                    pane: Pane(Playlists),
                ),
                // (
                //     name: "Directories (6)",
                //     pane: Pane(Directories),
                // ),
                (
                    name: "Search (6)",
                    pane: Pane(Search),
                ),
                // (
                //     name: "Visualizer (8)",
                //     pane: Pane(Cava),
                // ),
            ],

            cava: (
                framerate: 60, // default 60
                autosens: true, // default true
                sensitivity: 100, // default 100
                lower_cutoff_freq: 50, // not passed to cava if not provided
                higher_cutoff_freq: 10000, // not passed to cava if not provided

                input: (
                    method: Fifo,
                    source: "/tmp/mpd.fifo",
                    sample_rate: 44100,
                    channels: 2,
                    sample_bits: 16,
                ),

                smoothing: (
                    noise_reduction: 77, // default 77
                    monstercat: false, // default false
                    waves: false, // default false
                ),

                // this is a list of floating point numbers thats directly passed to cava
                // they are passed in order that they are defined
                eq: [],
            ),

            keybinds: (
                global: {
                    "q":       Quit,
                    "p":       TogglePause,
                    "s":       Stop,
                    ">":       NextTrack,
                    "<":       PreviousTrack,
                    ",":       VolumeDown,
                    ".":       VolumeUp,
                    ":":       CommandMode,

                    "<Tab>":   NextTab,
                    "<S-Tab>": PreviousTab,
                    "1":       SwitchToTab("Queue (1)"),
                    "2":       SwitchToTab("Albums (2)"),
                    "3":       SwitchToTab("Album Artists (3)"),
                    "4":       SwitchToTab("Artists (4)"),
                    "5":       SwitchToTab("Playlists (5)"),
                    // "6":       SwitchToTab("Directories (6)"),
                    "6":       SwitchToTab("Search (6)"),
                    // "8":       SwitchToTab("Visualizer (8)"),

                    "f":       SeekForward,
                    "z":       ToggleRepeat,
                    "x":       ToggleRandom,
                    "c":       ToggleConsumeOnOff, // Skip OneShot mode
                    "v":       ToggleSingleOnOff, // Skip OneShot mode
                    "b":       SeekBack,
                    "~":       ShowHelp,
                    "u":       Update,
                    "U":       Rescan,
                    "I":       ShowCurrentSongInfo,
                    "O":       ShowOutputs,
                    "P":       ShowDecoders,
                    "R":       AddRandom,
                },
                navigation: {
                    "k":         Up,
                    "j":         Down,
                    "h":         Left,
                    "l":         Right,
                    "<Up>":      Up,
                    "<Down>":    Down,
                    "<Left>":    Left,
                    "<Right>":   Right,

                    "g":         Top,
                    "G":         Bottom,
                    "<C-u>":     UpHalf,
                    "<C-d>":     DownHalf,
                    "J":         MoveDown,
                    "K":         MoveUp,

                    "<C-k>":     PaneUp,
                    "<C-j>":     PaneDown,
                    "<C-h>":     PaneLeft,
                    "<C-l>":     PaneRight,
                    "N":         PreviousResult,
                    "a":         Add,
                    "A":         AddAll,
                    "r":         Rename,
                    "n":         NextResult,
                    "<Space>":   Select,
                    "<C-Space>": InvertSelection,
                    "<CR>":      Confirm,
                    "i":         FocusInput,
                    "/":         EnterSearch,
                    "<C-c>":     Close,
                    "<Esc>":     Close,
                    "D":         Delete,
                    "B":         ShowInfo,
                },
                queue: {
                    "D":       DeleteAll,
                    "<CR>":    Play,
                    "<C-s>":   Save,
                    "a":       AddToPlaylist,
                    "d":       Delete,
                    "C":       JumpToCurrent,
                    "X":       Shuffle,
                },
            ),
        )
      '';

      ".config/rmpc/themes/${themeName}.ron".text = let
        light = color.hex.light;
        dark = color.hex.dark;

        bg = light.base;
        text = light.text;
        accent = dark.mauve;
        accentHL = dark.red;
        surface = dark.base;
      in ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]
        (
            default_album_art_path: None,
            show_song_table_header: true,
            draw_borders: true,
            format_tag_separator: " | ",
            browser_column_widths: [20, 38, 42],
            modal_backdrop: false,

            // Don't set backgrounds so it doesn't look super shitty in dark terminals
            background_color: None,
            header_background_color: None,
            modal_background_color: None,

            text_color: "#${text}",
            preview_label_style: (fg: "yellow"),
            preview_metadata_group_style: (fg: "yellow", modifiers: "Bold"),

            tab_bar: (
                enabled: true,
                active_style: (fg: "#${text}", bg: "#${accent}", modifiers: "Bold|Italic"),
                inactive_style: (),
            ),

            highlighted_item_style: (fg: "#${accentHL}", modifiers: "Bold|Italic"), // Currently playing
            current_item_style: (fg: "#${text}", bg: "#${accentHL}", modifiers: "Bold"), // Tracks list cursor
            borders_style: (fg: "#${accent}", modifiers: "Bold"),
            highlight_border_style: (fg: "#${accent}", modifiers: "Bold"),

            symbols: (
                song: "󰝚",
                dir: "",
                playlist: "󰲸",
                marker: "+",
                ellipsis: "",
                song_style: None,
                dir_style: None,
                playlist_style: None,
            ),

            // The stuff shown in the status bar (on the progress bar)
            level_styles: (
                info: (fg: "#${accent}", bg: "#${surface}"),
                warn: (fg: "#${dark.yellow}", bg: "#${surface}"),
                error: (fg: "#${dark.red}", bg: "#${surface}"),
                debug: (fg: "#${dark.green}", bg: "#${surface}"),
                trace: (fg: "#${dark.mauve}", bg: "#${surface}"),
            ),

            progress_bar: (
                // symbols: ["[", "-", ">", " ", "]"],
                symbols: ["█", "█", "█", "█", "█"],
                track_style: (fg: "#${surface}"),
                elapsed_style: (fg: "#${accent}"),
                thumb_style: (fg: "#${accentHL}"), // "The draggable part"
            ),

            scrollbar: (
                symbols: ["│", "█", "▲", "▼"],
                track_style: (fg: "#${surface}"),
                ends_style: (fg: "#${accentHL}"),
                thumb_style: (fg: "#${accentHL}"), // "The draggable part"
            ),

            song_table_format: [
                (
                    prop: (
                        kind: Property(Artist),
                        style: (fg: "#${text}"),
                        default: (kind: Text("Unknown"))
                    ),
                    width: "20%",
                ),
                (
                    prop: (
                        kind: Property(Title),
                        style: (fg: "#${text}"),
                        default: (kind: Text("Unknown"))
                    ),
                    width: "35%",
                ),
                (
                    prop: (
                        kind: Property(Album),
                        style: (fg: "#${text}"),
                        default: (kind: Text("Unknown Album"), style: (fg: "white"))
                    ),
                    width: "30%",
                ),
                (
                    prop: (
                        kind: Property(Duration),
                        style: (fg: "#${text}"),
                        default: (kind: Text("-"))
                    ),
                    width: "15%",
                    alignment: Right,
                ),
            ],

            components: {},

            layout: Split(
                direction: Vertical,
                panes: [
                    (
                        pane: Pane(Header),
                        size: "2",
                    ),
                    (
                        pane: Pane(Tabs),
                        size: "3",
                    ),
                    (
                        pane: Pane(TabContent),
                        size: "100%",
                    ),
                    (
                        pane: Pane(ProgressBar),
                        size: "1",
                    ),
                ],
            ),

            header: (
                rows: [
                    // Top Row
                    (
                        left: [
                            (
                                kind: Text("["),
                                style: (fg: "#${accentHL}", modifiers: "Bold")
                            ),
                            (
                                kind: Property(Status(StateV2(
                                    playing_label: "Playing",
                                    paused_label: "Paused",
                                    stopped_label: "Stopped"))
                                ),
                                style: (fg: "#${accentHL}", modifiers: "Bold")
                            ),
                            (
                                kind: Text("]"),
                                style: (fg: "#${accentHL}", modifiers: "Bold")
                            )
                        ],

                        center: [
                            (
                                kind: Property(Song(Title)),
                                style: (fg: "#${accentHL}", modifiers: "Bold"),
                                default: (
                                    kind: Text("No Song"),
                                    style: (fg: "#${text}", modifiers: "Bold")
                                )
                            )
                        ],

                        right: [
                            (
                                kind: Property(Widget(ScanStatus)),
                                style: (fg: "#${accentHL}")
                            ),
                            (
                                kind: Property(Widget(Volume)),
                                style: (fg: "#${accentHL}")
                            )
                        ]
                    ),

                    // Bottom Row
                    (
                        left: [
                            (
                                kind: Property(Status(Elapsed)),
                                style: (fg: "#${text}")
                            ),
                            (
                                kind: Text(" / "),
                                style: (fg: "#${text}")
                            ),
                            (
                                kind: Property(Status(Duration)),
                                style: (fg: "#${text}")
                            ),
                            (
                                kind: Text(" ("),
                                style: (fg: "#${text}")
                            ),
                            (
                                kind: Property(Status(Bitrate)),
                                style: (fg: "#${text}")
                            ),
                            (
                                kind: Text(" kbps)"),
                                style: (fg: "#${text}")
                            )
                        ],

                        center: [
                            (
                                kind: Property(Song(Artist)),
                                style: (fg: "#${text}", modifiers: "Bold"),
                                default: (
                                    kind: Text("Unknown"),
                                    style: (fg: "#${text}", modifiers: "Bold")
                                )
                            ),
                            (
                                kind: Text(" - "),
                                style: (fg: "#${text}")
                            ),
                            (
                                kind: Property(Song(Album)),
                                style: (fg: "#${text}"),
                                default: (
                                    kind: Text("Unknown Album"),
                                    style: (fg: "#${text}")
                                )
                            )
                        ],

                        right: [
                            // (
                            //     kind: Property(Widget(States(
                            //         active_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                            //         inactive_style: (fg: "#${text}"),
                            //         separator_style: (fg: "#${text}"))),
                            //     )
                            //     // style: (fg: "dark_gray")
                            // ),
                            (
                                kind: Property(Status(RepeatV2(
                                    on_label: "Repeat (z)",
                                    off_label: "Repeat (z)",
                                    on_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                                    off_style: (fg: "#${text}"),
                                ))),
                            ),
                            (
                                kind: Text(" / "),
                                style: (fg: "#${text}"),
                            ),

                            (
                                kind: Property(Status(RandomV2(
                                    on_label: "Random (x)",
                                    off_label: "Random (x)",
                                    on_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                                    off_style: (fg: "#${text}"),
                                ))),
                            ),
                            (
                                kind: Text(" / "),
                                style: (fg: "#${text}"),
                            ),

                            (
                                kind: Property(Status(ConsumeV2(
                                    on_label: "Consume (c)",
                                    oneshot_label: "Consume OS (c)",
                                    off_label: "Consume (c)",
                                    on_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                                    oneshot_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                                    off_style: (fg: "#${text}"),
                                ))),
                            ),
                            (
                                kind: Text(" / "),
                                style: (fg: "#${text}"),
                            ),

                            (
                                kind: Property(Status(SingleV2(
                                    on_label: "Single (v)",
                                    oneshot_label: "Single OS (v)",
                                    off_label: "Single (v)",
                                    on_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                                    oneshot_style: (fg: "#${accentHL}", modifiers: "Bold|Underlined"),
                                    off_style: (fg: "#${text}")
                                ))),
                            ),
                        ]
                    ),
                ],
            ),

            browser_song_format: [
                (
                    kind: Group([
                        (kind: Property(Track)),
                        (kind: Text(" ")),
                    ])
                ),
                (
                    kind: Group([
                        (kind: Property(Artist)),
                        (kind: Text(" - ")),
                        (kind: Property(Title)),
                    ]),
                    default: (kind: Property(Filename))
                ),
            ],

            lyrics: (
                timestamp: false
            ),

            cava: (
                // symbols that will be used to draw the bar in the visualiser, in ascending order of
                // fill fraction
                bar_symbols: ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'],
                // similar to bar_symbols but these are used for the top-down rendering, meaning for orientation
                // "Horizontal" and "Top"
                inverted_bar_symbols: ['▔', '🮂', '🮃', '▀', '🮄', '🮅', '🮆', '█'],

                // bg_color: "black", // background color, defaults to rmpc's bg color if not provided
                bar_width: 1, // width of a single bar in columns
                bar_spacing: 1, // free space between bars in columns

                // Possible values are "Top", "Bottom" and "Horizontal". Top makes the bars go from top to
                // bottom, "Bottom" is from bottom up, and "Horizontal" is split in the middle with bars going
                // both down and up from there.
                // Using non-default symbols with "Top" and "Horizontal" may produce undesired output.
                orientation: Bottom,

                // Colors can be configured in three different ways: a single color, different colors
                // per row and a gradient. You can use the same colors as everywhere else. Only specify
                // one of these:

                // Every bar symbol will be red
                // bar_color: Single("red"),

                // The first two rows(two lowest amplitudes) will be red, after that two green rows
                // and the rest will be blue. You can have as many as you want here. The last value
                // will be used if the height exceeds the length of this array.
                // bar_color: Rows([
                //     "red",
                //     "red",
                //     "green",
                //     "green",
                //     "blue",
                // ]),

                // A simple color gradient. This is a map where keys are percent values of the height
                // where the color starts. After that it is linearly interpolated towards the next value.
                // In this example, the color will start at green for the lowest amplitudes, go towards
                // blue at half amplitudes and finishing as red for the highest values. Keys must be between
                // 0 and 100 and if the first or last key are not 0 and 100 respectively, the lowest and highest
                // value will be used as 0 and 100. Only hex and RGB colors are supported here and your terminal
                // must support them as well!
                bar_color: Gradient({
                      0: "#${accent}",
                    100: "#${accentHL}",
                }),
            ),
        )
      '';
    };
  };
}
