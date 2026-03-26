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
      supportedDistros = [
        "humble"
        "jazzy"
        "rolling"
      ];

    in
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        mkDroneEnv = distro: self.lib.mkDroneEnv { inherit pkgs distro; };

        # Generate the Attribute Set for all distros
        # Result: { humble = <drv>; jazzy = <drv>; ... }
        distroPackages = builtins.listToAttrs (
          map (distro: {
            name = distro;
            value = mkDroneEnv distro;
          }) supportedDistros
        );

        # Result: { microcdr = <drv>; fastdds = <drv>; ... }
        flatTools = builtins.listToAttrs (
          map (p: {
            name = p.pname or p.name;
            value = p;
          }) (pkgs.lib.collect pkgs.lib.isDerivation pkgs.droneTools)
        );

      in
      {
        packages =
          distroPackages
          // flatTools
          // {
            default = distroPackages.humble;
          };

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
      overlays.default = nixpkgs.lib.composeManyExtensions [
        nix-ros-overlay.overlays.default # Adds rosPackages
        gazebo-sim-overlay.overlays.default # Adds gazebo tools
        nixgl.overlay # Adds nixGL
        (import ./overlays/default.nix) # Adds my custom droneTools
      ];

      overlays.droneTools = import ./overlays/default.nix;
      overlays.ros = nix-ros-overlay.overlays.default;

      lib.mkDroneEnv =
        { pkgs, distro }:
        let
          system = pkgs.system;
        in
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

          meta = {
            description = "AeroNix - ${distro} environment";
            homepage = "https://github.com/mark26745/AeroNix";
            license = pkgs.lib.licenses.mit;
            platforms = pkgs.lib.platforms.linux;
            maintainers = [ "mark26745" ];
          };
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
