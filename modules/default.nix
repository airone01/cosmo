{
  cosmoLib,
  lib,
  ...
}: {
  # Meta
  options.cosmo.settings.schemaVersion = cosmoLib.mkJsonOption {
    type = lib.types.int;
    default = 1;
    title = "JSON schema version";
    description = "The schema version.";
  };
}
