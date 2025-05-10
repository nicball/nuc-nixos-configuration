{ pkgs, config, ... }:

{
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-compute-runtime ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # GPU virtualization
  # boot.kernelParams = [ "intel_iommu=on" ];
  # boot.kernelModules = [ "kvmgt" "vfio-iommu-type1" "mdev" ];
  # boot.extraModprobeConfig = ''
  #   options i915 enable_gvt=1 enable_guc=0
  #   options kvm_intel nested=1
  #   options kvm_intel emulate_invalid_guest_state=0
  #   options kvm ignore_msrs=1 report_ignored_msrs=0
  # '';
  # services.udev.extraRules = ''SUBSYSTEM=="vfio", MODE="0660", GROUP="kvm"'';
  # security.pam.loginLimits = [
  #   {
  #     domain = "@kvm";
  #     item = "memlock";
  #     type = "-";
  #     value = "unlimited";
  #   }
  # ];
}
