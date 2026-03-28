# I have not decided yet if this file is anti-pattern in itself or needed for
# this MVP to work.
{
  config,
  lib,
  cosmoLib,
  ...
}: let
  cfg = config.cosmo.settings;
in {
  options.cosmo.settings.system.timezone = cosmoLib.mkJsonOption {
    type = lib.types.str;
    default = "UTC";
    title = "System Timezone";
    description = "The timezone of the system (e.g., Europe/Paris or America/New_York).";
  };

  config = {
    time.timeZone = lib.mkDefault cfg.system.timezone;
  };
}
