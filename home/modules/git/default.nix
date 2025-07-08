{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) git;
in {
  options.modules.git = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf git.enable {
    programs.git = {
      enable = true;

      # userEmail = "christoph.urlacher@protonmail.com";
      # userName = "Christoph Urlacher";

      userEmail = git.userEmail;
      userName = git.userName;

      signing = {
        signByDefault = git.signCommits;
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };

      lfs.enable = true;
      diff-so-fancy = {
        enable = true;
        changeHunkIndicators = true;
        markEmptyLines = false;
        stripLeadingSymbols = true;
      };

      extraConfig = {
        core = {
          compression = 9;
          # whitespace = "error";
          preloadindex = true;
        };

        init = {
          defaultBranch = "main";
        };

        gpg = {
          ssh = {
            allowedSignersFile = "~/.ssh/allowed_signers";
          };
        };

        status = {
          branch = true;
          showStash = true;
          showUntrackedFiles = "all";
        };

        pull = {
          default = "current";
          rebase = true;
        };

        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
        };

        rebase = {
          autoStash = true;
          missingCommitsCheck = "warn";
        };

        diff = {
          context = 3;
          renames = "copies";
          interHunkContext = 10;
        };

        interactive = {
          diffFilter = "${pkgs.diff-so-fancy}/bin/diff-so-fancy --patch";
          singlekey = true;
        };

        log = {
          abbrevCommit = true;
          graphColors = "blue,yellow,cyan,magenta,green,red";
        };

        branch = {
          sort = "-committerdate";
        };

        tag = {
          sort = "-taggerdate";
        };

        pager = {
          branch = false;
          tag = false;
        };

        url = {
          "ssh://git@gitea.local.chriphost.de:222/christoph/" = {
            insteadOf = "gitea:";
          };
          "git@github.com:" = {
            insteadOf = "github:";
          };
        };
      };
    };
  };
}
