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
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    gazebo-sim-overlay.url = "github:muellerbernd/gazebo-sim-overlay";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
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
          overlays = [
            self.overlays.default
          ];
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

        devShells =
          let
            shells = builtins.mapAttrs (
              name: env:
              pkgs.mkShell {
                name = "drone-shell-${name}";
                packages = [ env ];
                shellHook = ''
                  	      export ROS_DISTRO=${name}
                  	      echo "Shell Hook for ${name} environment is loaded!"
                  	      export ROS_DISTRO=${name}
                  	      export QT_QPA_PLATFORM=xcb
                  	      export QT_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"
                  	      export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-5.15/plugins"
                  	      export QT_STYLE_OVERRIDE=Fusion
                  	      export QT_PALETTE_OVERRIDE=dark
                  	      export GZ_CONFIG_PATH="${env}/share/gz"
                  	      export LD_LIBRARY_PATH="${env}/lib:$LD_LIBRARY_PATH"
                  	      export CMAKE_PREFIX_PATH="${env}:$CMAKE_PREFIX_PATH"
                  	      echo "--- Drone Lab: ${name} Environment Loaded ---"
                  	      '';
              }
            ) distroPackages;
          in
          shells
          // {
            default = shells.humble;
          };

      }
    )
    // {
      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          nix-ros-overlay.overlays.default # Adds rosPackages
          gazebo-sim-overlay.overlays.default # Adds gazebo tools
          nixgl.overlay # Adds nixGL
          (import ./overlays/default.nix) # Adds my custom droneTools
        ];
        droneTools = import ./overlays/default.nix;
        ros = nix-ros-overlay.overlays.default;
      };
      lib.mkDroneEnv =
        { pkgs, distro }:
        let
          system = pkgs.system;
          nixGLIntel = nixgl.packages.${system}.nixGLIntel;
          gz-pkgs = gazebo-sim-overlay.legacyPackages.${system};
          rosPkgs = pkgs.rosPackages.${distro};
          rosEnv = rosPkgs.buildEnv {
            name = "ros-base-${distro}";
            paths = [
              rosPkgs.ros-core
              rosPkgs.rosbridge-suite
              rosPkgs.rviz2
              rosPkgs.sensor-msgs
            ];
          };
        in
        pkgs.symlinkJoin {
          name = "drone-env-${distro}";
          paths = [
            rosEnv

            gz-pkgs.gz-harmonic
            gz-pkgs.ignition.msgs
            gz-pkgs.ignition.utils2
            gz-pkgs.ignition.tools2
            gz-pkgs.ignition.common5
            gz-pkgs.ignition.msgs10
            gz-pkgs.sdformat_14

            pkgs.protobuf
            pkgs.pkg-config

            pkgs.colcon
            pkgs.droneTools.dds.microxrcedds-agent
            pkgs.droneTools.rosPkgs.px4-msgs
            pkgs.droneTools.rosPkgs.px4-ros-com
            # Tools
            pkgs.droneTools.mavlink.mavp2p
            pkgs.droneTools.mavlink.mavlink2rest

            nixGLIntel
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
          description = "A basic ROS 2 Humble drone environment";
        };
        default = self.templates.basic;
      };
    };
}
