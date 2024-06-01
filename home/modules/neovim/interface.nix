{
  lib,
  mylib,
  pkgs,
  ...
}: [
  {
    name = "lualine";
    pkg = pkgs.vimPlugins.lualine-nvim;
    lazy = false;
    config = ''
      function(_, opts)
        require("lualine").setup(opts)
      end
    '';
    opts = {
      extensions = ["fzf" "chadtree" "neo-tree" "toggleterm" "trouble"];

      options = {
        always_divide_middle = true;
        globalstatus = true;
        ignore_focus = ["neo-tree" "chadtree"];
        section_separators = {
          left = "";
          right = "";
          # left = "";
          # right = "";
        };

        component_separators = {
          left = "";
          right = "";
          # left = "";
          # right = "";
        };
      };

      sections = {
        lualine_a = [
          {
            name = "mode";
            # extraConfig = {
            #   separator = {
            #     left = "";
            #   };
            #   right_padding = "2";
            # };
          }
        ];
        lualine_b = ["branch" "diff" "diagnostics"];
        lualine_c = [
          {
            name = "filename";
            extraConfig = {
              path = 1;
            };
          }
        ];

        lualine_x = ["filetype" "encoding" "fileformat"];
        lualine_y = ["progress" "searchcount" "selectioncount"];
        lualine_z = [
          {
            name = "location";
            # extraConfig = {
            #   separator = {
            #     right = "";
            #   };
            #   left_padding = "2";
            # };
          }
        ];
      };

      tabline = {
        lualine_a = ["buffers"];
        lualine_z = ["tabs"];
      };
    };
  }

  {
    name = "noice";
    pkg = pkgs.vimPlugins.noice-nvim;
    dependencies = [
      {
        name = "nui"; # For noice
        pkg = pkgs.vimPlugins.nui-nvim;
        lazy = false;
      }
    ];
    lazy = false;
    config = ''
      function(_, opts)
        require("noice").setup(opts)
      end
    '';
    opts = {
      presets = {
        bottom_search = false;
        command_palette = true;
        long_message_to_split = true;
        inc_rename = true;
        lsp_doc_border = true;
      };

      lsp = {
        documentation = {
          opts = {
            lang = "markdown";
            replace = true;
            render = "plain";
            border = "rounded"; # single or rounded
            format = ["{message}"];
            win_options = {
              concealcursor = "n";
              conceallevel = 3;
            };
          };
          view = "hover";
        };

        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
      };

      notify = {
        enabled = true;
      };

      popupmenu = {
        enabled = true;
        backend = "nui"; # cmp completion is broken
      };

      # cmdline.enabled = false;
      # messages.enabled = false;

      routes = [
        # Hide inline search count info
        {
          filter = {
            event = "msg_show";
            kind = "search_count";
          };
          opts = {skip = true;};
        }
      ];
    };
  }

  {
    name = "notify";
    pkg = pkgs.vimPlugins.nvim-notify;
    lazy = false;
    config = ''
      function(_, opts)
        vim.notify = require("notify")
        require("notify").setup(opts)
      end
    '';
  }

  {
    name = "telescope";
    pkg = pkgs.vimPlugins.telescope-nvim;
    dependencies = [
      {
        name = "plenary"; # For telescope
        pkg = pkgs.vimPlugins.plenary-nvim;
      }
      {
        name = "telescope-undo";
        pkg = pkgs.vimPlugins.telescope-undo-nvim;
      }
      {
        name = "telescope-ui-select";
        pkg = pkgs.vimPlugins.telescope-ui-select-nvim;
      }
      {
        name = "telescope-fzf-native";
        pkg = pkgs.vimPlugins.telescope-fzf-native-nvim;
      }
    ];
    lazy = false;
    config = let
      extensions = mylib.generators.toLuaObject [
        "undo"
        "ui-select"
        "fzf"
      ];
    in ''
      function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)

        for i, extension in ipairs(${extensions}) do
            telescope.load_extension(extension)
        end
      end
    '';
    opts = {
      defaults = {
        mappings = {
          i = {
            "<Esc>" = {__raw = ''function(...) return require("telescope.actions").close(...) end'';};
          };
        };
      };
    };
  }

  {
    name = "which-key";
    pkg = pkgs.vimPlugins.which-key-nvim;
    lazy = false;
    priority = 100;
    config = ''
      function(_, opts)
        require("which-key").setup(opts)
      end
    '';
  }
]
