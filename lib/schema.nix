{lib, ...}: let
  mapJsonType = nixType:
    if nixType.name == "bool" || nixType.name == "boolean"
    then "boolean"
    else if nixType.name == "str" || nixType.name == "string"
    then "string"
    else if nixType.name == "int" || nixType.name == "positive integer"
    then "integer"
    else "string"; # fallback for complex types; MVP only

  # Check if a node in attribute tree is an actual defined option
  isOption = node: lib.isAttrs node && node ? _type && node._type == "option";

  # Convert a Nix option node into a JSON schema property block
  optionToProperty = opt: let
    # Grab the custom metadata we injected in mkJsonOption
    meta = opt.jsonMetadata or {};
  in
    {
      type = mapJsonType opt.type;
      title = meta.title or "";
      description = opt.description or "";
    }
    // lib.optionalAttrs (opt ? default && opt.default != null) {
      inherit (opt) default;
    };

  # The recursive engine
  walk = attrs: let
    # Filter out internal NixOS junk that might leak into the tree
    cleanAttrs = lib.filterAttrs (n: y: n != "_module") attrs;
  in {
    type = "object";
    properties =
      lib.mapAttrs (
        name: value:
          if isOption value
          then optionToProperty value
          else walk value
      )
      cleanAttrs;
  };
in {
  # Main function that will be called from flake
  generateSchema = optionsTree: {
    "$schema" = "http://json-schema.org/draft-07/schema#";
    title = "COSMO System Schema";
    type = "object";
    inherit ((walk optionsTree)) properties;
  };
}
