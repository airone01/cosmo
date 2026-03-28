{lib, ...}: let
  schemaGenerator = import ./schema.nix {inherit lib;};
in {
  # Strict wrapper for Cosmo options
  mkJsonOption = {
    type,
    description,
    default ? null,
    title ? "",
    showIf ? null,
    ...
  }:
    (lib.mkOption {
      inherit type description default;
    })
    // {
      # Attach custom meta directly to Nix option so schema extractor can read it later
      jsonMetadata = {
        inherit title showIf;
      };
    };

  # Helper to upgrade old JSON schemas to current one
  # This is in prevision and theoretical, would need to be built upon
  migrateSchema = json:
    if json.schemaVersion == 1
    then json
    else throw "COSMO Error: Unsupported schemaVersion ${toString json.schemaVersion}";

  inherit (schemaGenerator) generateSchema;
}
