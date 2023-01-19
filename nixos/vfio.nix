{ config, pkgs, ... }:
{
  specialisation.vfio.configuration = {
    boot.extraModprobeConfig = "options vfio-pci ids=10de:2520,10de:228e";
    boot.extraModulePackages = [ pkgs.kvmfr ];
    boot.kernelModules = [ "kvm-intel" "wl" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" "kvmfr" ];
    boot.kernelParams = [ "intel_iommu=on" "hugepagesz=2M" "hugepages=4096" "kvmfr.static_size_mb=32" ];
    services.udev.extraRules = ''SUBSYSTEM=="kvmfr", OWNER="atilla", GROUP="kvm", MODE="0600"'';
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager looking-glass-client spice-gtk ntfs3g ];
    systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 atilla kvm -" ];
    virtualisation = {
      spiceUSBRedirection.enable = true;

      libvirtd = {
        enable = true;
        extraConfig = ''
          user="atilla"
        '';

        qemu = {
          package = pkgs.qemu_kvm;
          ovmf = {
            enable = true;
          };
          # 1000 is probably your userid
          verbatimConfig = ''
             namespaces = []
             user = "+1000"
             cgroup_device_acl = [
             "/dev/null", "/dev/full", "/dev/zero",
             "/dev/random", "/dev/urandom",
             "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
             "/dev/rtc","/dev/hpet", "/dev/vfio/vfio", "/dev/kvmfr0"
            ]
          '';
        };
      };
    };
  };
}

