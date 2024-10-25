{ pkgs, ... }:

{
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-compute-runtime ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
