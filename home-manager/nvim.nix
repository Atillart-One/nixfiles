{ config, pkgs, lib, ... }:

{
  home.packages = (with pkgs ;[
    gcc
    cargo
    nerdfonts
]); 
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    extraPackages = (with pkgs ;[ tree-sitter nodejs ripgrep fd unzip ]);
  };

  home.file = {
    "nyoom.nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "shaunsingh";
        repo = "nyoom.nvim";
        rev = "ec3faaacb52207e99c54a66e04f5425adb772faa";
        sha256 = "0r3xwrjw07f8n35fb3s9w4kkavsciqwsw408bfi7vdfyax5fxc5x";
      };
	target = ".config/nvim";
	recursive = true;
    };
  };
}

