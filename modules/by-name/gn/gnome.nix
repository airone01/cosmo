{
  config,
  cosmoLib,
  lib,
  pkgs,
  ...
}: let
  # Grab safely parsed JSON settings
  cfg = config.cosmo.settings;
in {
  # Meta
  options.cosmo.settings.desktop.gnome = cosmoLib.mkJsonOption {
    type = lib.types.bool;
    default = false;
    title = "Enable GNOME Desktop";
    description = "Installs the GNOME desktop environment and GDM.";
  };

  # Implementation
  # mkDefault should be a necessity, otherwise we're making a walled garden
  config = lib.mkIf (cfg.desktop.gnome == true) {
    services = {
      displayManager.gdm.enable = lib.mkDefault true;
      desktopManager.gnome.enable = lib.mkDefault true;
    };

    # Opinionated additions example
    environment.systemPackages = [pkgs.gnome-tweaks];
  };
}
