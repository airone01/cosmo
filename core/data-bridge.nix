{lib, ...}: let
  # Locate JSON config
  # IRL implementation would be more complex; This is an example
  targetJson =
    if builtins.pathExists /etc/cosmo/cosmo.json
    then /etc/cosmo/cosmo.json
    else ../default-cosmo.json;

  rawJson = builtins.fromJSON (builtins.readFile targetJson);

  cosmoLib = import ../lib {inherit lib;};

  safeSettings = cosmoLib.migrateSchema rawJson;

  # We give power users a way to override the computed config
  overridesPath = /etc/cosmo/overrides.nix;
  hasOverrides = builtins.pathExists overridesPath;
in {
  # Import user's manual Nix overrides if exists
  imports = lib.optional hasOverrides overridesPath;

  config = {
    # Inject cosmoLib into all modules globally so no one has to callPackage it
    _module.args.cosmoLib = cosmoLib;

    # Feed parsed JSON into module system
    cosmo.settings = safeSettings;
  };
}
