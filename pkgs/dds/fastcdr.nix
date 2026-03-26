{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "fastcdr";
  version = "2.3.5";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Fast-CDR";
    rev = "v${version}";
    hash = "sha256-gWENB3zqnFll047Jv+GL4k497wrzNaIaVTbXY7feRNQ=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=11"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "eProsima FastCDR library for serialization mechanisms";
    homepage = "https://github.com/eProsima/Fast-CDR";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
