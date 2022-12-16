{ config, pkgs, ... }:

let
  vfio-start = pkgs.writeShellScriptBin "vfio-start" ''
    set -x

    # unbind the vtconsoles (you might have more vtconsoles than me, you can check by running: dir /sys/class/vtconsole
    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind

    # unbind the efi framebruffer
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

    # avoid race condition (I'd start with 5, and if the gpu passes inconsistently, change this value to be higher)
    sleep 4

    # detach the gpu
    virsh nodedev-detach pci_0000_01_00_0
    virsh nodedev-detach pci_0000_01_00_1

    # load vfio
    modprobe vfio-pci
 '';
 
  vfio-stop = pkgs.writeShellScriptBin "vfio-stop" ''
    set -x

    # rebind the gpu
    virsh nodedev-reattach pci_0000_01_00_1
    virsh nodedev-reattach pci_0000_01_00_0

    # Rebind VT consoles
    echo 1 > /sys/class/vtconsole/vtcon0/bind
    echo 1 > /sys/class/vtconsole/vtcon1/bind
 '';
in
{
  boot.extraModprobeConfig = "options vfio-pci ids=10de:2520,10de:228e";
  boot.kernelModules = [ "kvm-intel" "wl" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.kernelParams = [ "intel_iommu=on" ];
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager looking-glass-client spice-gtk vfio-start vfio-stop ];
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
}

