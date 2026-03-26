{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
  pkg-config,
  fastdds,
  fastcdr,
  microcdr,
  asio,
  tinyxml-2,
}:

stdenv.mkDerivation rec {
  pname = "micro-xrce-dds-client";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Micro-XRCE-DDS-Client";
    rev = "v${version}";
    sha256 = "sha256-WTtPbLL2ERNN6n/aT2mhNgG7VjGYXyPeO6ddhYfJTVE=";
  };

  nativeBuildInputs = [
    cmake
    git
    pkg-config
  ];

  buildInputs = lib.filter (x: x != null) [
    fastdds
    fastcdr
    asio
    tinyxml-2
    microcdr
  ];

  cmakeFlags = [
    "-DUCLIENT_SUPERBUILD=OFF"
    "-DUCLIENT_BUILD_TESTS=OFF"
    "-DUCLIENT_BUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "A Micro XRCE-DDS client.";
    homepage = "https://github.com/eProsima/Micro-XRCE-DDS-Agent";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
