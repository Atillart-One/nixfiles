{ config, pkgs, ... }:

{
  # Disable service
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.dnsname.enable = true;
    };
  };

  # Enable flatpak
  services.flatpak.enable = true;
	
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.fonts;
      pathsToLink = [ "/share/fonts" ];
    };
  in {
    # Create an FHS mount to support flatpak host icons/fonts
    "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
    "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  };
  
  # Steam fix
  security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
  if (action.id === "org.freedesktop.NetworkManager.settings.modify.system") {
    var name = polkit.spawn(["cat", "/proc/" + subject.pid + "/comm"]);
    if (name.includes("steam")) {
      polkit.log("ignoring steam NM prompt");
      return polkit.Result.NO;
    }
  }
});
'';
}
