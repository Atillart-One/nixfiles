# This file defines overlays
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    looking-glass-client = prev.looking-glass-client.overrideAttrs (oldAttrs: rec {
      version = "B6";
      src = prev.fetchFromGitHub {
        owner = "gnif";
        repo = "LookingGlass";
        rev = version;
        sha256 = "sha256-6vYbNmNJBCoU23nVculac24tHqH7F4AZVftIjL93WJU=";
        fetchSubmodules = true;
      };

      buildInputs = [ prev.looking-glass-client.buildInputs final.pipewire final.pulseaudio final.libsamplerate ];

      cmakeFlags = [ "-DOPTIMIZE_FOR_NATIVE=OFF" "-DENABLE_X11=yes" "-DENABLE_WAYLAND=yes" "-DENABLE_PULSAUDIO=yes" "-DENABLE_PIPEWIRE=yes" ];
    });

    kvmfr = prev.linuxKernel.packages.linux_6_1.kvmfr.overrideAttrs (oldAttrs: rec {
      patches = [ ];
    });

    hilbish = prev.callPackage "${prev.path}/pkgs/shells/hilbish" {
      buildGoModule = args: prev.buildGoModule (args // {
        version = "2.0.1";

        src = prev.fetchFromGitHub {
          owner = "Rosettea";
          repo = "Hilbish";
          rev = "v2.0.1";
          hash = "sha256-5GPJVusF3/WbEE5VH45Wyxq40wbNxgjO8QI2cLMpdN0=";
          fetchSubmodules = true;
        };

        vendorSha256 = "sha256-Kiy1JR3X++naY2XNLpnGujrNQt7qlL0zxv8E96cHmHo=";

        postInstall = ''
          mkdir -p "$out/share/hilbish"

          cp .hilbishrc.lua $out/share/hilbish/
          cp -r docs -t $out/share/hilbish/
          cp -r libs -t $out/share/hilbish/
          cp -r nature -t $out/share/hilbish/
        '';
      });
    };
  };
}

