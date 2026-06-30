# Here goes the stuff that will only be enabled on the desktop
{
  pkgs,
  nixosConfig,
  config,
  hostname,
  lib,
  mylib,
  username,
  inputs,
  ...
}: {
  config = {
    homemodules = {
      btop.cuda = true;

      # This has been relocated here from the default config,
      # because it forces en-US keyboard layout.
      fcitx.enable = true;

      waybar.monitors = ["DP-1" "DP-2"];
      vscode.enable = true;
      zed.enable = true;
    };

    programs = {
      claude-code = {
        enable = true;
        enableMcpIntegration = true;
      };

      # NOTE: Starts extremely slow
      ghostty = {
        enable = true;
        enableFishIntegration = true;
        systemd.enable = true;

        settings = {
          theme = "catppuccin-mocha";
          font-family = config.homemodules.color.font;
          font-size = 12;
          window-padding-x = 10;
          window-padding-y = 10;
          adjust-cursor-thickness = 1;

          cursor-click-to-move = true;
          gtk-single-instance = true;
          # link-previews = true;
        };

        themes = let
          color = config.homemodules.color;
        in {
          catppuccin-mocha = {
            background = color.hex.base;
            cursor-color = color.hex.rosewater;
            foreground = color.hex.text;
            palette = [
              "0=#${color.hex.surface1}"
              "1=#${color.hex.red}"
              "2=#${color.hex.green}"
              "3=#${color.hex.yellow}"
              "4=#${color.hex.blue}"
              "5=#${color.hex.pink}"
              "6=#${color.hex.teal}"
              "7=#${color.hex.subtext1}"
              "8=#${color.hex.surface2}"
              "9=#${color.hex.red}"
              "10=#${color.hex.green}"
              "11=#${color.hex.yellow}"
              "12=#${color.hex.blue}"
              "13=#${color.hex.pink}"
              "14=#${color.hex.teal}"
              "15=#${color.hex.subtext0}"
            ];
            selection-background = color.hex.surface1;
            selection-foreground = color.hex.text;
          };
        };
      };

      mcp = {
        enable = true;
        servers = {
          nixos = {
            command = "uvx";
            args = ["mcp-nixos"];
          };
          svelte = {
            # claude mcp add -t stdio -s [scope] svelte -- npx -y @sveltejs/mcp
            command = "npx";
            args = ["-y" "@sveltejs/mcp"];
            type = "stdio";
          };
          shadcn = {
            # npx shadcn@latest mcp init --client claude
            command = "npx";
            args = ["-y" "shadcn@latest" "mcp"];
          };
        };
      };

      opencode = {
        enable = true;
        enableMcpIntegration = true;
        extraPackages = with pkgs; [
          # opencode-claude-auth # Installed using npm
        ];

        # Writes opencode.json
        settings = {
          attachment = {
            image = {
              auto_resize = true;
              max_width = 2000;
              max_height = 2000;
              max_base64_bytes = 5242880;
            };
          };
          autoupdate = false;
          compaction = {
            auto = true;
            prune = true;
            reserved = 10000;
          };
          default_agent = "plan";
          enabled_providers = [
            "opencode"
            "opencode-go"
            "anthropic"
            "lmstudio"
          ];
          formatter = {
            nixfmt = {
              disabled = true;
            };
            alejandra = {
              command = ["alejandra" "$FILE"];
              extensions = [".nix"];
            };
            perltidy = {
              command = ["perltidy" "$FILE"];
              extensions = [".pl"];
            };
          };
          lsp = {
            nixd = {
              command = ["nixd"];
              extensions = [".nix"];
              initialization = {
                preferences = {
                  nixd = {
                    nixpkgs = {expr = "import <nixpkgs> {}";};
                    options = {
                      nixos = {expr = "(builtins.getFlake \"/home/${username}/NixFlake\").nixosConfigurations.${hostname}.options";};
                      home-manager = {expr = "(builtins.getFlake \"/home/${username}/NixFlake\").nixosConfigurations.\"${hostname}\".options.home-manager.users.type.getSubOptions []";};
                    };
                    diagnostic = {
                      suppress = ["sema-escaping-with" "var-bind-to-this" "escaping-this-with"];
                    };
                  };
                };
              };
            };
            perlnavigator = {
              command = ["perlnavigator"];
              extensions = [".pl"];
              initialization = {
                preferences = {};
              };
            };
            # perlpls = {
            #   command = ["pls"];
            #   extensions = [".pl"];
            #   initialization = {
            #     preferences = {
            #       perl = {
            #         perlcritic = {enabled = false;};
            #         syntax = {enabled = true;};
            #       };
            #     };
            #   };
            # };
            r-language-server = {
              command = ["R" "--no-echo" "-e" "languageserver::run()"];
              extensions = [".r" ".rmd" ".quarto"];
            };
          };
          permission = {
            "*" = "ask";
            "bash" = {
              "*" = "ask";
              "ls *" = "allow";
              "find *" = "ask"; # Don't want find -exec
              "file *" = "allow";
              "wc *" = "allow";
              "grep *" = "allow";
              "rg *" = "allow";
              "test *" = "allow";
              "echo *" = "allow";
              "which *" = "allow";
              "pwd *" = "allow";
              "dirname *" = "allow";
              "basename *" = "allow";
              "readlink *" = "allow";

              "cat *.env" = "deny";
              "cat *.env.*" = "deny";
              "cat *.env.example" = "allow";
              "printenv *" = "deny";
              "env *" = "deny";

              "nix eval *" = "allow";
              "nix flake metadata *" = "allow";
              "nix flake show *" = "allow";
              "nix path-info *" = "allow";
              "nix why-depends *" = "allow";
              "nix derivation show *" = "allow";
              "nix store ping *" = "allow";
              "nix stire diff-closures *" = "allow";

              "git status *" = "allow";
              "git log *" = "allow";
              "git diff *" = "allow";
            };
            "external_directory" = {
              "/nix/store/**" = "allow";
              "/tmp" = "allow";
              "/tmp/*" = "allow";
            };
            "read" = {
              "*" = "allow";
              "*.env" = "deny";
              "*.env.*" = "deny";
              "*.env.example" = "allow";
            };
            "grep" = "allow";
            "glob" = "allow";
            "lsp" = "allow";
            "skill" = "allow";
            "task" = "ask";
            "todowrite" = "allow";
            "webfetch" = "allow";
            "websearch" = "allow";
            "question" = "allow";
          };
          plugin = [
            "opencode-claude-auth@latest" # https://github.com/griffinmartin/opencode-claude-auth
            "@tarquinen/opencode-dcp@latest" # better compacting
            "opencode-lmstudio@0.3.1"
            # "@slkiser/opencode-quota"
          ];
          share = "disabled";
          shell = "fish";
          snapshot = false;
          watcher = {
            ignore = ["node_modules/**" "dist/**" ".git/**"];
          };
        };

        # Writes tui.json
        tui = {
          theme = "system";
          diff_style = "auto";
          mouse = true;
          attention = {
            enabled = true;
            notifications = true;
            sound = true;
            volume = "0.3";
          };
        };

        agents = {};
        commands = {};
        context = '''';
        skills = {};
        tools = {};
      };
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

      rider-unity = pkgs.jetbrains.rider.overrideAttrs (attrs: {
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
        # Intel FPGA design software
        # quartus-prime-lite

        jetbrains.clion
        # jetbrains.rust-rover
        # jetbrains.pycharm-professional
        # jetbrains.idea-ultimate
        # jetbrains.webstorm
        # jetbrains.rider
        # ghidra # launch with _JAVA_AWT_WM_NONREPARENTING=1 (use programs.ghidra)
        # zed-editor # Using module
        # vscode # Using module

        # Unity Stuff
        # unityhub
        # rider-unity
        # dotnetCore
        # mono
        # steam-run-free # nix-alien doesn't seem to run unity apps, this does...

        inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default
        (blender.override {cudaSupport = true;})
        godot_4
        (obs-studio.override {cudaSupport = true;})
        kdePackages.kdenlive
        # davinci-resolve
        krita
        makemkv
        lrcget
        # msty
        # jellyfin-media-player # CVE, can't install
        jellyfin-desktop
        jellyfin-mpv-shim
        # tidal-hifi
        # tidal-dl-ng # TODO: Borked
        # spotdl
        tiddl
        picard
        handbrake
        teamspeak6-client

        # virt-manager # use system program option
        virt-viewer
        gnome-boxes # doesn't list VMs imported using virsh

        steam-devices-udev-rules
      ];

      file = lib.mkMerge [
        {
          # ".local/share/applications/jetbrains-rider.desktop".source = let
          #   desktopFile = pkgs.makeDesktopItem {
          #     name = "jetbrains-rider";
          #     desktopName = "Rider";
          #     exec = "\"${rider-unity}/bin/rider\"";
          #     icon = "rider";
          #     type = "Application";
          #     # Don't show desktop icon in search or run launcher
          #     extraConfig.NoDisplay = "true";
          #   };
          # in "${desktopFile}/share/applications/jetbrains-rider.desktop";

          ".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source =
            ../../../config/mangohud/MangoHud.conf;
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
          "org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08"
          "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08"
          "io.github.Foldex.AdwSteamGtk"
          "com.vysp3r.ProtonPlus"
          # "net.davidotek.pupgui2"

          "org.prismlauncher.PrismLauncher"
          "com.usebottles.bottles"
          "io.github.lawstorant.boxflat"

          "org.onlyoffice.desktopeditors"

          # "com.unity.UnityHub"
        ];

        overrides = {
          "org.prismlauncher.PrismLauncher".Context = {
            filesystems = [
              "${config.home.homeDirectory}/Downloads"

              "/tmp" # To allow temporary world folder creation for datapack installation
            ];
          };

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

          "com.vysp3r.ProtonPlus".Context = {
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

          "com.unity.UnityHub".Context = {
            filesystems = [
              "${config.home.homeDirectory}/Unity"
              "${config.home.homeDirectory}/Projects"
            ];
          };
        };
      };
    };
  };
}
