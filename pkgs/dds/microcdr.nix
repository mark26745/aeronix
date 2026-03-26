{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "microcdr";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "eProsima";
    repo = "Micro-CDR";
    rev = "v${version}";
    hash = "sha256-OfxsJGD3nFb+92rYvZ/YF6Qj+3ZwDiSIvZaTq3flcJQ=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_SKIP_RPATH=OFF"
    "-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=OFF"
  ];

  postInstall = ''
    # If the build nested everything inside a versioned folder...
    if [ -d "$out/microcdr-${version}" ]; then
      echo "Flattening nested microcdr folder..."
      mv $out/microcdr-${version}/* $out/
      rmdir $out/microcdr-${version}
    fi

    # Standard Nix cleanup for 64-bit systems
    if [ -d "$out/lib64" ]; then
      mv $out/lib64/* $out/lib/
      rmdir $out/lib64
    fi
  '';

  meta = with lib; {
    description = "Micro CDR serialization library";
    license = licenses.asl20;
  };
}
