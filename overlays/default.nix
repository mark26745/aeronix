final: prev:
let
  dds-pkgs = import ../pkgs/dds final prev;

  ros-pkgs = import ../pkgs/rosPkgs {
    inherit (final) lib rosPackages;
    distro = "humble";
  };

  mavlink-pkgs = prev.lib.makeScope final.newScope (
    self:
    prev.lib.filesystem.packagesFromDirectoryRecursive {
      callPackage = self.callPackage;
      directory = ../pkgs/mavlink;
    }
  );

in
{
  inherit (dds-pkgs)
    fastcdr
    microcdr
    fastdds
    microxrcedds-client
    ;

  droneTools = {
    dds = dds-pkgs;
    rosPkgs = ros-pkgs;
    mavlink = mavlink-pkgs;
  };
}
