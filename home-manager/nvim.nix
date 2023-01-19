{ config, pkgs, lib, ... }:

{
  home.packages = (with pkgs ;[
    gcc
    vimPlugins.telescope-fzf-native-nvim
    rnix-lsp
    sumneko-lua-language-server
    (nerdfonts.override { fonts = [ "MPlus" "IBMPlexMono" "Gohu" ]; })
  ]);
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    extraPackages = (with pkgs ;[ tree-sitter nodejs ripgrep fd unzip ]);
  };
}

