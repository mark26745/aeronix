final: prev:
let
  # Import your DDS set
  dds-pkgs = import ../pkgs/dds final prev;
in
{
  # 1. Provide the namespace exactly as you wanted
  dds = dds-pkgs;

  # 2. Spread them into the top-level so 'callPackage'
  # in other folders (like mavlink) can find them automatically.
  inherit (dds-pkgs)
    fastcdr
    microcdr
    fastdds
    microxrcedds-client
    ;

  # Example: If you have droneTools or other sets
  droneTools = prev.lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = final.callPackage;
    directory = ../pkgs;
  };
}
