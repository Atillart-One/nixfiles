{ config, pkgs, ... }:
{
  specialisation.vfio.configuration = {
    boot.extraModprobeConfig = "options vfio-pci ids=10de:2520,10de:228e";
    boot.kernelModules = [ "kvm-intel" "wl" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    boot.kernelParams = [ "intel_iommu=on" "hugepagesz=2M" "hugepages=4096" ];
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager looking-glass-client spice-gtk ntfs3g ];
    virtualisation.spiceUSBRedirection.enable = true;
    systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0660 atilla kvm -"];
    virtualisation = {
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
          '';
        };
      };
    };
  };
}

