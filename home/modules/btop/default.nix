{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) btop;
in {
  options.modules.btop = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf btop.enable {
    programs.btop = {
      enable = true;
      package =
        if btop.cuda
        then pkgs.btop-cuda
        else pkgs.btop;

      # TODO: Use colors module
      themes = {
        # https://github.com/catppuccin/btop/tree/main
        catppuccin-latte = ''
          # Main background, empty for terminal default, need to be empty if you want transparent background
          theme[main_bg]="#eff1f5"

          # Main text color
          theme[main_fg]="#4c4f69"

          # Title color for boxes
          theme[title]="#4c4f69"

          # Highlight color for keyboard shortcuts
          theme[hi_fg]="#1e66f5"

          # Background color of selected item in processes box
          theme[selected_bg]="#bcc0cc"

          # Foreground color of selected item in processes box
          theme[selected_fg]="#1e66f5"

          # Color of inactive/disabled text
          theme[inactive_fg]="#8c8fa1"

          # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
          theme[graph_text]="#dc8a78"

          # Background color of the percentage meters
          theme[meter_bg]="#bcc0cc"

          # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
          theme[proc_misc]="#dc8a78"

          # CPU, Memory, Network, Proc box outline colors
          theme[cpu_box]="#8839ef" #Mauve
          theme[mem_box]="#40a02b" #Green
          theme[net_box]="#e64553" #Maroon
          theme[proc_box]="#1e66f5" #Blue

          # Box divider line and small boxes line color
          theme[div_line]="#9ca0b0"

          # Temperature graph color (Green -> Yellow -> Red)
          theme[temp_start]="#40a02b"
          theme[temp_mid]="#df8e1d"
          theme[temp_end]="#d20f39"

          # CPU graph colors (Teal -> Lavender)
          theme[cpu_start]="#179299"
          theme[cpu_mid]="#209fb5"
          theme[cpu_end]="#7287fd"

          # Mem/Disk free meter (Mauve -> Lavender -> Blue)
          theme[free_start]="#8839ef"
          theme[free_mid]="#7287fd"
          theme[free_end]="#1e66f5"

          # Mem/Disk cached meter (Sapphire -> Lavender)
          theme[cached_start]="#209fb5"
          theme[cached_mid]="#1e66f5"
          theme[cached_end]="#7287fd"

          # Mem/Disk available meter (Peach -> Red)
          theme[available_start]="#fe640b"
          theme[available_mid]="#e64553"
          theme[available_end]="#d20f39"

          # Mem/Disk used meter (Green -> Sky)
          theme[used_start]="#40a02b"
          theme[used_mid]="#179299"
          theme[used_end]="#04a5e5"

          # Download graph colors (Peach -> Red)
          theme[download_start]="#fe640b"
          theme[download_mid]="#e64553"
          theme[download_end]="#d20f39"

          # Upload graph colors (Green -> Sky)
          theme[upload_start]="#40a02b"
          theme[upload_mid]="#179299"
          theme[upload_end]="#04a5e5"

          # Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
          theme[process_start]="#209fb5"
          theme[process_mid]="#7287fd"
          theme[process_end]="#8839ef"
        '';
      };

      settings = {
        color_theme = "catppuccin-latte";
        truecolor = true;
        vim_keys = true;
        rounded_corners = true;
        graph_symbol = "braille";
        shown_boxes = "cpu gpu0 mem net proc";
        update_ms = 1000;
        proc_sorting = "memory";
        proc_tree = false;
        proc_mem_bytes = true;
        proc_cpu_graphs = true;

        #* Use /proc/[pid]/smaps for memory information in the process info box (very slow but more accurate)
        proc_info_smaps = false;

        #* In tree-view, always accumulate child process resources in the parent process.
        proc_aggregate = true;

        #* Sets the CPU stat shown in upper half of the CPU graph, "total" is always available.
        #* Select from a list of detected attributes from the options menu.
        cpu_graph_upper = "user";

        #* Sets the CPU stat shown in lower half of the CPU graph, "total" is always available.
        #* Select from a list of detected attributes from the options menu.
        cpu_graph_lower = "system";

        #* If gpu info should be shown in the cpu box. Available values = "Auto", "On" and "Off".
        show_gpu_info = "Off";

        show_uptime = true;
        check_temp = true; # Show cpu temperature
        show_coretemp = true;

        #* Set a custom mapping between core and coretemp, can be needed on certain cpus to get correct temperature for correct core.
        #* Use lm-sensors or similar to see which cores are reporting temperatures on your machine.
        #* Format "x:y" x=core with wrong temp, y=core with correct temp, use space as separator between multiple entries.
        #* Example: "4:0 5:1 6:3"
        cpu_core_map = "";

        temp_scale = "celsius";
        base_10_sizes = false;
        show_cpu_freq = true;

        #* Draw a clock at top of screen, formatting according to strftime, empty string to disable.
        #* Special formatting: /host = hostname | /user = username | /uptime = system uptime
        clock_format = "%X";

        #* Optional filter for shown disks, should be full path of a mountpoint, separate multiple values with whitespace " ".
        #* Begin line with "exclude=" to change to exclude filter, otherwise defaults to "most include" filter. Example: disks_filter="exclude=/boot /home/user".
        disks_filter = "";

        #* Show graphs instead of meters for memory values.
        mem_graphs = true;

        #* If swap memory should be shown in memory box.
        show_swap = true;

        #* Show swap as a disk, ignores show_swap value above, inserts itself after first disk.
        swap_disk = false;

        #* If mem box should be split to also show disks info.
        show_disks = true;

        #* Filter out non physical disks. Set this to False to include network disks, RAM disks and similar.
        only_physical = true;

        #* Read disks list from /etc/fstab. This also disables only_physical.
        use_fstab = true;

        #* Toggles if io activity % (disk busy time) should be shown in regular disk usage view.
        show_io_stat = true;

        #* Use network graphs auto rescaling mode, ignores any values set above and rescales down to 10 Kibibytes at the lowest.
        net_auto = true;

        #* Sync the auto scaling for download and upload to whichever currently has the highest scale.
        net_sync = true;

        #* "True" shows bitrates in base 10 (Kbps, Mbps). "False" shows bitrates in binary sizes (Kibps, Mibps, etc.). "Auto" uses base_10_sizes.
        base_10_bitrate = false;

        #* Show battery stats in top right if battery is present.
        show_battery = true;

        #* Which battery to use if multiple are present. "Auto" for auto detection.
        selected_battery = "Auto";

        #* Show power stats of battery next to charge indicator.
        show_battery_watts = true;

        #* Measure PCIe throughput on NVIDIA cards, may impact performance on certain cards.
        nvml_measure_pcie_speeds = true;

        #* Horizontally mirror the GPU graph.
        gpu_mirror_graph = false;
      };
    };
  };
}
