{
  pkg-config,
  stdenv,
  fetchFromGitHub,
  cmake,
  asio,
  tinyxml-2,
  openssl,
  fastcdr,
  foonathan-memory,
}:

stdenv.mkDerivation rec {
  pname = "fastdds";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Fast-DDS";
    rev = "v${version}";
    hash = "sha256-VVqKmv4yQkq7tt58JxHAxB2+1j9j9PoFGVX9Qm3FliA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fastcdr
    asio
    tinyxml-2
    openssl
    foonathan-memory
  ];

  cmakeFlags = [
    "-DCOMPILE_TOOLS=ON"
    "-DCHECK_DOCUMENTATION=OFF"
  ];
}
