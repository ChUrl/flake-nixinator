#!/usr/bin/env python3

import argparse
import os
import re
import shutil
import subprocess
from typing import cast
from urllib.request import urlretrieve

INIT_LUA: str = "/home/christoph/.config/nvim/init.lua"


def patch_paths(text: str, mappings: dict[str, str]) -> str:
    """Patches /nix/store paths in init.lua"""

    patched = text

    for old, new in mappings.items():
        print(f"Patching init.lua: {old} -> {new}")
        patched = patched.replace(old, new)

    return patched


def patch_various(text: str) -> str:
    """Patches various incompatibilities with NixVim init.lua"""

    # Install lazy
    print("Patching init.lua: Bootstrap lazy.nvim")
    patched = (
        """-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

"""
        + text
    )

    # print("Patching init.lua: Disabling vim.loader")
    # patched = patched.replace("vim.loader.enable(true)", "vim.loader.enable(false)")

    return patched


def copy_plugins(text: str, path: str) -> dict[str, str]:
    """Copies NeoVim plugins from the Nix Store"""

    os.makedirs(path, exist_ok=True)

    plugins_path: str = re.findall(r"\"(/nix/store/.*-lazy-plugins)\"", text)[0]
    print(f"Copying: {plugins_path} -> {path}/plugins")
    _ = shutil.copytree(plugins_path, f"{path}/plugins")

    treesitter_path: str = re.findall(
        r"\"(/nix/store/.*-vimplugin-nvim-treesitter.*)\"", text
    )[0]
    print(f"Copying: {treesitter_path} -> {path}/treesitter")
    _ = shutil.copytree(treesitter_path, f"{path}/treesitter")

    parsers_path: str = re.findall(r"\"(/nix/store/.*-treesitter-parsers)\"", text)[0]
    print(f"Copying: {parsers_path} -> {path}/parsers")
    _ = shutil.copytree(parsers_path, f"{path}/parsers")

    return {
        plugins_path: "./plugins",
        treesitter_path: "./treesitter",
        parsers_path: "./parsers",
    }


def write_file(text: str, path: str) -> None:
    """Write text to a file"""

    with open(path, "w") as file:
        _ = file.write(text)


# TODO: Could add etc. nvim/lsp/formatter/linter binaries here
# TODO: Needs "install recipe", as in most cases the download will be an archive
DOWNLOADS: list[tuple[str, str]] = [
    # (
    #     "https://github.com/neovim/neovim/releases/download/v0.11.6/nvim-linux-x86_64.tar.gz",
    #     "nvim",
    # ),
]


def download_binaries(path: str, urls: list[tuple[str, str]]) -> None:
    """Download required binaries"""

    os.makedirs(f"{path}/bin", exist_ok=True)

    def download(url: str, path: str) -> None:
        """Download from URL"""

        print(f"Downloading: {url}")
        _ = urlretrieve(url, path)

    for url, name in urls:
        download(url, f"{path}/bin/{name}")


def build_nvim(path: str) -> None:
    """Builds a static nvim binary against musl"""

    # TODO: Build etc. is working, but on the target system there are
    #       lua-ffi errors from noice.nvim with the static binary.
    #       This does not happen with nvim from system package repository.

    def run(command: list[str]) -> None:
        """Run a subprocess"""

        print(f"Running: {' '.join(command)}")
        _ = subprocess.run(command)

    os.makedirs(f"{path}/nvim-build", exist_ok=True)

    with open(f"{path}/nvim-build/build-nvim.sh", "w") as file:
        _ = file.write(
            "\n".join(
                [
                    "#!/bin/sh",
                    "git clone https://github.com/neovim/neovim",
                    "cd neovim",
                    "git checkout stable",
                    'make -j$(nproc) CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DSTATIC_BUILD=1"',
                    "make CMAKE_INSTALL_PREFIX=/workdir/install install",
                ]
            )
        )

    run(
        [
            "docker",
            "run",
            "--rm",
            "-it",
            "-v",
            f"{os.path.abspath(path)}/nvim-build:/workdir",
            "-w",
            "/workdir",
            "alpine:3.23.3",
            "/bin/sh",
            "-c",
            "apk add build-base cmake coreutils curl gettext-tiny-dev git && chmod +x ./build-nvim.sh && ./build-nvim.sh",
        ]
    )

    _ = shutil.copytree(f"{path}/nvim-build/install/bin", f"{path}/bin")
    _ = shutil.copytree(f"{path}/nvim-build/install/lib", f"{path}/lib")
    _ = shutil.copytree(f"{path}/nvim-build/install/share", f"{path}/share")

    _ = shutil.rmtree(f"{path}/nvim-build")


def bundle() -> None:
    """Creates a standalone NeoVim bundle from the NixVim configuration"""

    parser = argparse.ArgumentParser()
    _ = parser.add_argument(
        "--config",
        type=str,
        default=INIT_LUA,
        help="init.lua or other config file",
    )
    _ = parser.add_argument(
        "--out",
        type=str,
        default="./nvim_bundle",
        help="destination folder",
    )

    args = parser.parse_args()
    args.config = cast(str, args.config)
    args.out = cast(str, args.out)

    with open(args.config, "r") as file:
        patched_init_lua: str = file.read()

    path_mappings = copy_plugins(patched_init_lua, args.out)
    patched_init_lua = patch_paths(patched_init_lua, path_mappings)
    patched_init_lua = patch_various(patched_init_lua)
    write_file(patched_init_lua, f"{args.out}/init.lua")

    # build_nvim(args.out)
    # download_binaries(args.out, DOWNLOADS)


if __name__ == "__main__":
    bundle()
