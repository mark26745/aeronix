{
  description = "A custom ROS 2 project powered by AeroNix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    aeronix.url = "github:mark26745/aeronix";
    nixpkgs.follows = "aeronix/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      aeronix,
    }:
    let
      rosDistro = "humble";
      overlays = [
        aeronix.overlays.default
      ];
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        pkgs = import nixpkgs { inherit system overlays; };
        # Uses helper to create the env
        droneEnv = aeronix.lib.mkDroneEnv {
          inherit pkgs;
          distro = rosDistro;
        };
      in
      {
        packages.default = pkgs.symlinkJoin {
          name = "my-drone-app";
          paths = [ droneEnv ];
        };

        # 2. Define the development shell
        devShells.default = pkgs.mkShell {
          name = "aeronix-dev-shell";

          # Pull in the environment built by the SDK
          packages = [
            droneEnv
            pkgs.colcon
            pkgs.gdb
          ];

          shellHook = ''
            echo "🚀 Welcome to your AeroNix-powered workspace!"
            echo "ROS_DISTRO is set to ${rosDistro} via the AeroNix SDK."
          '';
        };
      }
    );
}
