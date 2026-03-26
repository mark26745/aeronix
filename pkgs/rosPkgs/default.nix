{
  lib,
  rosPackages,
  distro ? "humble",
}:

let
  rosDistro = rosPackages.${distro};
  droneRosScope = lib.makeScope rosDistro.newScope (self: {
    px4-msgs = self.callPackage ./px4-msgs.nix { };

    px4-ros-com = self.callPackage ./px4-ros-com.nix { };

  });
in
{
  inherit (droneRosScope) px4-msgs px4-ros-com;
}
