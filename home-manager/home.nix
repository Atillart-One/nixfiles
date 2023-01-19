# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays your own flake exports (from overlays dir):
      outputs.overlays.modifications
      # outputs.overlays.additions

      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  # TODO: Set your username
  home = {
    username = "atilla";
    homeDirectory = "/home/atilla";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    retroarchFull
    obsidian
    wezterm
    qbittorrent
    protonvpn-gui
    discord

    inputs.nix-gaming.packages.${pkgs.system}.wine-tkg

    (stdenv.mkDerivation rec {
      pname = "discord-screenaudio";
      version = "1.5.1";

      src = fetchFromGitHub {
        owner = "maltejur";
        repo = "discord-screenaudio";
        rev = "v${version}";
        sha256 = "sha256-c0HYknH8Z6BXQcU03P2XzZV+zw1zFIhgCg9IT7sT1Ms=";
        fetchSubmodules = true;
      };

      depsBuildBuild = [ buildPackages.stdenv.cc ];
      nativeBuildInputs = [ qt5.wrapQtAppsHook cmake pkg-config ];
      buildInputs = with qt5; with libsForQt5; [ pipewire qtbase qtwebengine knotifications kglobalaccel kxmlgui ];

      cmakeFlags = [
        "-DPipeWire_INCLUDE_DIRS=${pipewire.dev}/include/pipewire-0.3"
        "-DSpa_INCLUDE_DIRS=${pipewire.dev}/include/spa-0.2"
      ];
    })

  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Shell 
  programs.zsh.enable = true;
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  programs.zsh.prezto.enable = true;
  programs.zsh.prezto.pmodules = [ "environment" "terminal" "editor" "history" "directory" "spectrum" "utility" "syntax-highlighting" "history-substring-search" "autosuggestions" "archive" "completion" "prompt" ];
  programs.zsh.prezto.terminal.autoTitle = true;
  programs.zsh.initExtra = "alias vi='nvim'";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
