final: prev:
let
  call = final.callPackage;
in
rec {
  fastcdr = call ./fastcdr.nix { };

  microcdr = call ./microcdr.nix { };

  fastdds = call ./fastdds.nix {
    inherit fastcdr;
  };

  microxrcedds-client = call ./micro-xrce-dds-client.nix {
    inherit fastcdr microcdr fastdds;
  };

  microxrcedds-agent = call ./micro-xrce-dds-agent.nix {
    inherit
      microxrcedds-client
      fastcdr
      microcdr
      fastdds
      ;
    spdlog = prev.spdlog;
  };
}
