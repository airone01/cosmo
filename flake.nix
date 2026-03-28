{
  description = "COSMO: Configurable Opinionated System for Modular Options";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        lib,
        ...
      }: {
        packages.schema = let
          cosmoLib = import ./lib {inherit lib;};
          evaluatedOptions = inputs.self.nixosConfigurations.default.options.cosmo.settings;
          schemaObj = cosmoLib.generateSchema evaluatedOptions;
        in
          pkgs.writeText "cosmo-schema.json" (builtins.toJSON schemaObj);

        packages.default = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.schema;
      };

      flake = let
        # Recursive module discovery
        # In a real product we would be using import-tree or equivalent, but this is a MVP
        defaultMod = ./modules;
        gnomeMod = ./modules/by-name/gn/gnome.nix;
        timeMod = ./modules/by-name/ti/timezone.nix;

        # (simulate import-tree output)
        discoveredModules = {
          defaut = defaultMod;
          gnome = gnomeMod;
          timezone = timeMod;
        };
      in {
        # Export modules so third-party flakes can use them
        nixosModules = discoveredModules;

        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./core/data-bridge.nix

            # This avoids the all-packages.nix nightmare
            # This trick comes with its fair share of issues though.
            # Adding files make them evaluate all the time.
            # This is mitigated by a good CI (with conditional, separated builds that use a dependency tree)
            # Like OfBorg :-)
            (_: {
              imports = builtins.attrValues discoveredModules;
            })

            # Dummy hardware config for evaluation
            (_: {
              boot.loader.grub.devices = ["nodev"];
              fileSystems."/" = {
                device = "/dev/sda1";
                fsType = "ext4";
              };
              system.stateVersion = "23.11";
            })
          ];
        };
      };
    };
}
