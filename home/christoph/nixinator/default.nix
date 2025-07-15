# Here goes the stuff that will only be enabled on the desktop
{
  pkgs,
  nixosConfig,
  config,
  lib,
  mylib,
  ...
}: {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      btop.cuda = true;

      hyprland = {
        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = {
          "HDMI-A-1" = {
            width = 2560;
            height = 1440;
            rate = 144;
            x = 1920;
            y = 0;
            scale = 1;
          };

          "DP-1" = {
            width = 1920;
            height = 1080;
            rate = 60;
            x = 0;
            y = 0;
            scale = 1;
          };
        };

        workspaces = {
          "HDMI-A-1" = [1 2 3 4 5 6 7 8 9];
          "DP-1" = [10];
        };

        autostart = {
          delayed = [
            "fcitx5"
          ];
        };

        floating = [
          {
            class = "fcitx";
          }
        ];
      };

      waybar.monitor = "HDMI-A-1";
    };

    home = let
      # Extra config to make Rider Unity integration work
      dotnetCore = with pkgs.dotnetCorePackages;
        combinePackages [
          # sdk_6_0_1xx # Is EOL
          # sdk_7_0_3xx # Is EOL
          sdk_8_0_3xx
          sdk_9_0_3xx
        ];

      extra-path = with pkgs; [
        dotnetCore
        dotnetPackages.Nuget
        mono
        # msbuild

        # Add any extra binaries you want accessible to Rider here
      ];

      extra-lib = with pkgs; [
        # Add any extra libraries you want accessible to Rider here
      ];

      rider = pkgs.jetbrains.rider.overrideAttrs (attrs: {
        postInstall =
          ''
            # Wrap rider with extra tools and libraries
            mv $out/bin/rider $out/bin/.rider-toolless
            makeWrapper $out/bin/.rider-toolless $out/bin/rider \
              --argv0 rider \
              --prefix PATH : "${lib.makeBinPath extra-path}" \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}"

            # Making Unity Rider plugin work!
            # The plugin expects the binary to be at /rider/bin/rider,
            # with bundled files at /rider/
            # It does this by going up two directories from the binary path
            # Our rider binary is at $out/bin/rider, so we need to link $out/rider/ to $out/
            shopt -s extglob
            ln -s $out/rider/!(bin) $out/
            shopt -u extglob
          ''
          + attrs.postInstall or "";
      });
    in {
      packages = with pkgs; [
        # quartus-prime-lite # Intel FPGA design software

        # Don't want heavy IDE's on the laptop
        jetbrains.clion
        jetbrains.rust-rover
        jetbrains.pycharm-professional
        # jetbrains.idea-ultimate
        # jetbrains.webstorm

        # Unity Stuff
        # unityhub

        rider
        dotnetCore
        mono

        blender
        godot_4
        obs-studio
        kdePackages.kdenlive
        krita
        makemkv
        msty

        steam-devices-udev-rules
      ];

      file = lib.mkMerge [
        {
          ".local/share/applications/jetbrains-rider.desktop".source = let
            desktopFile = pkgs.makeDesktopItem {
              name = "jetbrains-rider";
              desktopName = "Rider";
              exec = "\"${rider}/bin/rider\"";
              icon = "rider";
              type = "Application";
              # Don't show desktop icon in search or run launcher
              extraConfig.NoDisplay = "true";
            };
          in "${desktopFile}/share/applications/jetbrains-rider.desktop";

          ".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source = ../../../config/mangohud/MangoHud.conf;
        }
        (lib.optionalAttrs (mylib.modules.contains config.home.packages pkgs.makemkv) {
          ".MakeMKV/settings.conf".source =
            config.lib.file.mkOutOfStoreSymlink
            "${nixosConfig.sops.templates."makemkv-settings.conf".path}";
        })
      ];

      # Do not change.
      # This marks the version when NixOS was installed for backwards-compatibility.
      stateVersion = "22.05";
    };

    services = {
      flatpak = {
        packages = [
          "com.valvesoftware.Steam"
          "com.valvesoftware.Steam.Utility.steamtinkerlaunch"
          "net.davidotek.pupgui2"

          "org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08"
          "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08"

          "org.prismlauncher.PrismLauncher"
          "com.usebottles.bottles"
          "io.github.lawstorant.boxflat"
        ];

        overrides = {
          "com.valvesoftware.Steam".Context = {
            filesystems = [
              "${config.home.homeDirectory}/Games"

              # This is Proton-GE installed from flatpak. ProtonUpQT doesn't require it.
              "/var/lib/flatpak/runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
            ];
          };

          "net.davidotek.pupgui2".Context = {
            filesystems = [
              "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam"
              "${config.home.homeDirectory}/Games"
            ];
          };

          "com.usebottles.bottles".Context = {
            filesystems = [
              "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam"
              "${config.home.homeDirectory}/Games"
            ];
          };
        };
      };
    };

    # This has been relocated here from the default config,
    # because it forces en-US keyboard layout.
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        waylandFrontend = true;

        addons = with pkgs; [
          fcitx5-gtk
          # fcitx5-configtool
          catppuccin-fcitx5

          libsForQt5.fcitx5-qt # QT5
          libsForQt5.fcitx5-chinese-addons

          qt6Packages.fcitx5-qt # QT6
          qt6Packages.fcitx5-chinese-addons
        ];

        settings = {
          inputMethod = {
            GroupOrder = {
              "0" = "Default";
            };

            "Groups/0" = {
              # Group Name
              Name = "Default";

              # Layout
              "Default Layout" = "us";

              # Default Input Method
              DefaultIM = "pinyin";
            };

            "Groups/0/Items/0" = {
              # Name
              Name = "keyboard-us";

              # Layout
              # Layout=
            };

            "Groups/0/Items/1" = {
              # Name
              Name = "pinyin";

              # Layout
              # Layout=
            };
          };

          globalOptions = {
            Hotkey = {
              # Enumerate when press trigger key repeatedly
              EnumerateWithTriggerKeys = true;

              # Temporally switch between first and current Input Method
              # AltTriggerKeys=

              # Enumerate Input Method Forward
              # EnumerateForwardKeys=

              # Enumerate Input Method Backward
              # EnumerateBackwardKeys=

              # Skip first input method while enumerating
              EnumerateSkipFirst = false;

              # Enumerate Input Method Group Forward
              # EnumerateGroupForwardKeys=

              # Enumerate Input Method Group Backward
              # EnumerateGroupBackwardKeys=

              # Activate Input Method
              # ActivateKeys=

              # Deactivate Input Method
              # DeactivateKeys=
            };

            "Hotkey/TriggerKeys" = {
              "0" = "Super+space";
            };

            "Hotkey/PrevPage" = {
              "0" = "Up";
            };

            "Hotkey/NextPage" = {
              "0" = "Down";
            };

            "Hotkey/PrevCandidate" = {
              "0" = "Shift+Tab";
            };

            "Hotkey/NextCandidate" = {
              "0" = "Tab";
            };

            "Hotkey/TogglePreedit" = {
              "0" = "Control+Alt+P";
            };

            "Behavior" = {
              # Active By Default
              ActiveByDefault = false;

              # Reset state on Focus In
              resetStateWhenFocusIn = "No";

              # Share Input State
              ShareInputState = "All";

              # Show preedit in application
              PreeditEnabledByDefault = true;

              # Show Input Method Information when switch input method
              ShowInputMethodInformation = true;

              # Show Input Method Information when changing focus
              showInputMethodInformationWhenFocusIn = false;

              # Show compact input method information
              CompactInputMethodInformation = false;

              # Show first input method information
              ShowFirstInputMethodInformation = true;

              # Default page size
              DefaultPageSize = 5;

              # Override Xkb Option
              OverrideXkbOption = false;

              # Custom Xkb Option
              # CustomXkbOption=

              # Force Enabled Addons
              # EnabledAddons=

              # Force Disabled Addons
              # DisabledAddons=

              # Preload input method to be used by default
              PreloadInputMethod = true;

              # Allow input method in the password field
              AllowInputMethodForPassword = false;

              # Show preedit text when typing password
              ShowPreeditForPassword = false;

              # Interval of saving user data in minutes
              AutoSavePeriod = 30;
            };
          };

          addons = {
            chttrans.globalSection = {
              # Translate engine
              Engine = "OpenCC";

              # Toggle key
              # Hotkey=

              # Enabled Input Methods
              # EnabledIM=

              # OpenCC profile for Simplified to Traditional
              # OpenCCS2TProfile=

              # OpenCC profile for Traditional to Simplified
              # OpenCCT2SProfile=
            };

            classicui.globalSection = {
              # Vertical Candidate List
              "Vertical Candidate List" = false;

              # Use mouse wheel to go to prev or next page
              WheelForPaging = true;

              # Font
              Font = "Sans 12";

              # Menu Font
              MenuFont = "Sans 12";

              # Tray Font
              TrayFont = "Sans Bold 10";

              # Tray Label Outline Color
              TrayOutlineColor = "#000000";

              # Tray Label Text Color
              TrayTextColor = "#ffffff";

              # Prefer Text Icon
              PreferTextIcon = false;

              # Show Layout Name In Icon
              ShowLayoutNameInIcon = true;

              # Use input method language to display text
              UseInputMethodLanguageToDisplayText = true;

              # Theme
              Theme = "catppuccin-latte-lavender";

              # Dark Theme
              DarkTheme = "catppuccin-mocha-lavender";

              # Follow system light/dark color scheme
              UseDarkTheme = true;

              # Follow system accent color if it is supported by theme and desktop
              UseAccentColor = true;

              # Use Per Screen DPI on X11
              PerScreenDPI = true;

              # Force font DPI on Wayland
              ForceWaylandDPI = 0;

              # Enable fractional scale under Wayland
              EnableFractionalScale = true;
            };

            clipboard.globalSection = {
              # Trigger Key
              # TriggerKey=

              # Paste Primary
              # PastePrimaryKey=

              # Number of entries
              "Number of entries" = 5;
            };

            cloudpinyin.globalSection = {
              # Minimum Pinyin Length
              MinimumPinyinLength = 4;

              # Backend
              Backend = "GoogleCN";

              # Proxy
              # Proxy=
            };

            cloudpinyin.sections = {
              "Toggle Key" = {
                "0" = "Control+Alt+Shift+C";
              };
            };

            fullwidth.globalSection = {
              # Toggle key
              # Hotkey=
            };

            imselector.globalSection = {
              # Trigger Key
              # TriggerKey=

              # Trigger Key for only current input context
              # TriggerKeyLocal=

              # Hotkey for switching to the N-th input method
              # SwitchKey=

              # Hotkey for switching to the N-th input method for only current input context
              # SwitchKeyLocal=
            };

            keyboard.globalSection = {
              # Page size
              PageSize = 5;

              # Enable emoji in hint
              EnableEmoji = false;

              # Enable emoji in quickphrase
              EnableQuickPhraseEmoji = false;

              # Choose key modifier
              "Choose Modifier" = "Alt";

              # Enable hint by default
              EnableHintByDefault = false;

              # Trigger hint mode for one time
              # "One Time Hint Trigger"=

              # Use new compose behavior
              UseNewComposeBehavior = true;

              # Type special characters with long press
              EnableLongPress = false;
            };

            keyboard.sections = {
              "PrevCandidate" = {
                "0" = "Shift+Tab";
              };

              "NextCandidate" = {
                "0" = "Tab";
              };

              "Hint Trigger" = {
                "0" = "Control+Alt+H";
              };

              "LongPressBlocklist" = {
                "0" = "konsole";
              };
            };

            notifications.globalSection = {
              # Hidden Notifications
              # HiddenNotifications=
            };

            pinyin.globalSection = {
              # Shuangpin Profile
              ShuangpinProfile = "Ziranma";

              # Show current shuangpin mode
              ShowShuangpinMode = true;

              # Page size
              PageSize = 7;

              # Enable Spell
              SpellEnabled = false;

              # Enable Symbols
              SymbolsEnabled = true;

              # Enable Chaizi
              ChaiziEnabled = false;

              # Enable Characters in Unicode CJK Extension B
              ExtBEnabled = true;

              # Enable Cloud Pinyin
              CloudPinyinEnabled = true;

              # Cloud Pinyin Index
              CloudPinyinIndex = 2;

              # Show animation when Cloud Pinyin is loading
              CloudPinyinAnimation = true;

              # Always show Cloud Pinyin place holder
              KeepCloudPinyinPlaceHolder = false;

              # Preedit Mode
              PreeditMode = "Composing pinyin";

              # Fix embedded preedit cursor at the beginning of the preedit
              PreeditCursorPositionAtBeginning = true;

              # Show complete pinyin in preedit
              PinyinInPreedit = false;

              # Enable Prediction
              Prediction = false;

              # Prediction Size
              PredictionSize = 10;

              # Action when switching input method
              SwitchInputMethodBehavior = "Commit current preedit";

              # Forget word
              # ForgetWord=

              # Select 2nd Candidate
              # SecondCandidate=

              # Select 3rd Candidate
              # ThirdCandidate=

              # Use Keypad as Selection key
              UseKeypadAsSelection = false;

              # Use BackSpace to cancel the selection
              BackSpaceToUnselect = true;

              # Number of Sentences
              "Number of sentence" = 2;

              # Prompt long word length when input length over (0 for disable)
              LongWordLengthLimit = 4;

              # Key to trigger quickphrase
              # QuickPhraseKey=

              # Use V to trigger quickphrase
              VAsQuickphrase = false;

              # FirstRun
              FirstRun = false;
            };

            pinyin.sections = {
              "PrevPage" = {
                "0" = "Up";
              };

              "NextPage" = {
                "0" = "Down";
              };

              "PrevCandidate" = {
                "0" = "Shift+Tab";
              };

              "NextCandidate" = {
                "0" = "Tab";
              };

              "CurrentCandidate" = {
                "0" = "space";
                "1" = "KP_Space";
              };

              "CommitRawInput" = {
                "0" = "Return";
                "1" = "KP_Enter";
                "2" = "Control+Return";
                "3" = "Control+KP_Enter";
                "4" = "Shift+Return";
                "5" = "Shift+KP_Enter";
                "6" = "Control+Shift+Return";
                "7" = "Control+Shift+KP_Enter";
              };

              "ChooseCharFromPhrase" = {
                "0" = "bracketleft";
                "1" = "bracketright";
              };

              "FilterByStroke" = {
                "0" = "grave";
              };

              "QuickPhraseTriggerRegex" = {
                "0" = ".(/|@)$";
                "1" = "^(www|bbs|forum|mail|bbs)''.";
                "2" = "^(http|https|ftp|telnet|mailto):";
              };

              "Fuzzy" = {
                # ue -> ve
                VE_UE = true;

                # Common Typo
                NG_GN = true;

                # Inner Segment (xian -> xi'an)
                Inner = true;

                # Inner Segment for Short Pinyin (qie -> qi'e)
                InnerShort = true;

                # Match partial finals (e -> en, eng, ei)
                PartialFinal = true;

                # Match partial shuangpin if input length is longer than 4
                PartialSp = false;

                # u <-> v
                V_U = false;

                # an <-> ang
                AN_ANG = false;

                # en <-> eng
                EN_ENG = false;

                # ian <-> iang
                IAN_IANG = false;

                # in <-> ing
                IN_ING = false;

                # u <-> ou
                U_OU = false;

                # uan <-> uang
                UAN_UANG = false;

                # c <-> ch
                C_CH = false;

                # f <-> h
                F_H = false;

                # l <-> n
                L_N = false;

                # s <-> sh
                S_SH = false;

                # z <-> zh
                Z_ZH = false;

                # Correction Layout
                Correction = "None";
              };
            };

            punctuation.globalSection = {
              # Toggle key
              # Hotkey=

              # Half width punctuation after latin letter or number
              HalfWidthPuncAfterLetterOrNumber = true;

              # Type paired punctuations together (e.g. Quote)
              TypePairedPunctuationsTogether = false;

              # Enabled
              Enabled = true;
            };

            quickphrase.globalSection = {
              # Trigger Key
              # TriggerKey=

              # Choose key modifier
              "Choose Modifier" = "None";

              # Enable Spell check
              Spell = true;

              # Fallback Spell check language
              FallbackSpellLanguage = "en";
            };

            spell.sections = {
              "ProviderOrder" = {
                "0" = "Presage";
                "1" = "Custom";
                "2" = "Enchant";
              };
            };

            table.globalSection = {
              # Modify dictionary
              # ModifyDictionaryKey=

              # Forget word
              # ForgetWord=

              # Lookup pinyin
              # LookupPinyinKey=

              # Enable Prediction
              Prediction = false;

              # Prediction Size
              PredictionSize = 10;
            };

            unicode.sections = {
              "TriggerKey" = {
                "0" = "Control+Alt+Shift+U";
              };

              "DirectUnicodeMode" = {
                "0" = "Control+Shift+U";
              };
            };

            waylandim.globalSection = {
              # Detect current running application (Need restart)
              DetectApplication = true;
            };

            xcb.globalSection = {
              # Allow Overriding System XKB Settings
              "Allow Overriding System XKB Settings" = true;

              # Always set layout to be only group layout
              AlwaysSetToGroupLayout = true;
            };
          };
        };
      };
    };
  };
}
