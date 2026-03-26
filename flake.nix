{
  description = "AeroNix: A pure, multi-distro Nix SDK for ROS 2 and Drone Simulation";

  nixConfig = {
    extra-substituters = [
      "https://ros.cachix.org"
      "https://attic.iid.ciirc.cvut.cz/ros"
    ];
    extra-trusted-public-keys = [
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
    ];
  };

  inputs = {
    nixpkgs.follows = "nix-ros-overlay/nixpkgs"; # IMPORTANT!!!
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    gazebo-sim-overlay.url = "github:muellerbernd/gazebo-sim-overlay";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-ros-overlay,
      nixgl,
      gazebo-sim-overlay,
      ...
    }:
    let
      # 1. Supported Distros - Add or remove versions here
      supportedDistros = [
        "humble"
        "jazzy"
        "rolling"
      ];

      # 2. Shared Overlay logic
      overlays = [
        self.overlays.default
        nix-ros-overlay.overlays.default
        gazebo-sim-overlay.overlays.default
        nixgl.overlay
      ];
    in
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system overlays; };

        # 3. The "Factory" function: Creates a drone environment for a specific distro
        mkDroneEnv =
          distro:
          pkgs.rosPackages.${distro}.buildEnv {
            name = "drone-env-${distro}";
            paths = with pkgs.rosPackages.${distro}; [
              ament-cmake-core
              python-cmake-module
              desktop
              pkgs.colcon
              pkgs.mavproxy
              pkgs.droneTools.mavlink.mavp2p
              pkgs.droneTools.dds.micro-xrce-dds-agent
              nixgl.packages.${system}.nixGLIntel
            ];
          };

        # 4. Generate the Attribute Set for all distros
        # Result: { humble = <drv>; jazzy = <drv>; ... }
        distroPackages = builtins.listToAttrs (
          map (distro: {
            name = distro;
            value = mkDroneEnv distro;
          }) supportedDistros
        );

        # 5. Flatten the custom droneTools for the top level
        # Result: { microcdr = <drv>; fastdds = <drv>; ... }
        flatTools = builtins.listToAttrs (
          map (p: {
            name = p.pname or p.name;
            value = p;
          }) (pkgs.lib.collect pkgs.lib.isDerivation pkgs.droneTools)
        );

      in
      {
        # COMBINED OUTPUTS
        packages =
          distroPackages
          // flatTools
          // {
            default = distroPackages.humble;
          };

        # PER-DISTRO SHELLS: 'nix develop .#jazzy'
        devShells = builtins.mapAttrs (
          name: env:
          pkgs.mkShell {
            name = "drone-shell-${name}";
            packages = [ env ];
            shellHook = ''
              export ROS_DISTRO=${name}
              export QT_QPA_PLATFORM="xcb"
              echo "--- Drone Lab: ${name} Environment Loaded ---"
            '';
          }
        ) distroPackages;

      }
    )
    // {
      # GLOBAL OUTPUTS (Not system-dependent)
      overlays.default = import ./overlays/default.nix;

      # Export the function for child flakes to use
      lib.mkDroneEnv =
        { pkgs, distro }:
        pkgs.rosPackages.${distro}.buildEnv {
          # ... copy of logic or reference ...
        };

      templates = {
        basic = {
          path = ./templates/basic;
          description = "A basic ROS 2 Jazzy drone environment";
        };
        default = self.templates.basic;
      };
    };
}
