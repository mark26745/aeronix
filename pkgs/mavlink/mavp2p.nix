{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mavp2p";
  version = "1.3.2";
  commitDate = "2025-10-17";

  src = fetchFromGitHub {
    owner = "bluenviron";
    repo = "mavp2p";
    rev = "v${version}";
    hash = "sha256-OrpqU8IlJ8Vbqr18rubzZiOJZ4H00x/8uoEB7BaKiPc=";
  };

  vendorHash = "sha256-bYjl+yPlwVNqua2QyfJWXsXx/UVvWRr2roPetm5DEEk=";

  ldflags = [
    "-X main.version=v${version}"
    "-X main.buildDate=${commitDate}"
  ];

  meta = with lib; {
    description = "flexible and efficient Mavlink router";
    homepage = "https://github.com/bluenviron/mavp2p";
    license = licenses.mit;
  };
}
