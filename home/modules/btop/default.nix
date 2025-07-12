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
      settings = {
        #* Themes should be placed in "../share/btop/themes" relative to binary or "$HOME/.config/btop/themes"
        color_theme = "Default";
        truecolor = true;
        vim_keys = true;
        rounded_corners = true;
        graph_symbol = "braille";
        shown_boxes = "cpu gpu0 mem net proc";
        update_ms = 1000;
        proc_sorting = "memory";
        proc_tree = true;
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
