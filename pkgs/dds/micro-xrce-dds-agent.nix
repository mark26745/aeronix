{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  git,
  patchelf,
  microxrcedds-client,
  microcdr,
  cmake,
  pkg-config,
  fastdds,
  fastcdr,
  spdlog,
  asio,
  tinyxml2,
  foonathan-memory,
}:

stdenv.mkDerivation rec {
  pname = "micro-xrce-dds-agent";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Micro-XRCE-DDS-Agent";
    rev = "v${version}";
    sha256 = "sha256-nBJ+WuoZhB3+/NiYAH/l1r0BK1aFzAUfGpyOKpWC1sg=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    git
    patchelf
    pkg-config
  ];

  buildInputs = lib.filter (x: x != null) [
    fastdds
    microxrcedds-client
    spdlog
    fastcdr
    microcdr
    asio
    tinyxml2
    foonathan-memory
    stdenv.cc.cc.lib
  ];
  postFixup = ''
    wrapProgram $out/bin/MicroXRCEAgent \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}:$out/lib"
  '';

  cmakeFlags = [
    "-DUAGENT_SUPERBUILD=OFF"
    "-DUAGENT_LOGGER_PROFILE=OFF"
    "-DUAGENT_USE_SYSTEM_FASTDDS=ON"
    "-DUAGENT_USE_SYSTEM_FASTCDR=ON"
    "-DUAGENT_BUILD_EXECUTABLE=ON"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "A Micro XRCE-DDS Agent acting as a bridge between Micro XRCE-DDS Clients and the DDS world.";
    homepage = "https://github.com/eProsima/Micro-XRCE-DDS-Agent";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
