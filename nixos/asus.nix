{ config, pkgs, ... }:
{
  services.asusd.enable = true;
  services.supergfxd.enable = true;
  services.fstrim.enable = true;
  services.auto-cpufreq.enable = true;
}
