# This file defines overlays
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    looking-glass-client = prev.looking-glass-client.overrideAttrs (oldAttrs: rec {
      version = "B6-rc1";
      src = prev.fetchFromGitHub {
        owner = "gnif";
        repo = "LookingGlass";
        rev = version;
        hash = "sha256-ZFCfasEWG512n7FEKSIuzof0OAy5iTRJfntGsA5jumQ=";
	fetchSubmodules = true;
      };

      buildInputs = [ prev.looking-glass-client.buildInputs final.pipewire final.pulseaudio final.libsamplerate ];
    });
  };
}

