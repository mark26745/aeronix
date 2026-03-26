{
  lib,
  rustPlatform,
  pkg-config,
  clang,
  openssl,
  fetchFromGitHub,
  fetchurl,
  git,
}:
let
  # Pre-fetch the Vue file that the build script wants
  vue-js = fetchurl {
    url = "https://unpkg.com/vue@3.0.5/dist/vue.global.js";
    hash = "sha256-Wr5PnkpmZ3oQFRZLfDrI6fsePSMak5h8rW2rqq+mdWg";
  };

  highlight-css = fetchurl {
    url = "https://unpkg.com/highlight.js@10.6.0/styles/github.css";
    hash = "sha256-ja0z+lPRcUPYhi+sdtJJEKlXmCMywxJtCLxCQzKd2K0=";
  };

  highlight-js = fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.6.0/highlight.min.js";
    hash = "sha256-0vVFuyJuW8wdUK83s0XSRdzmO8B6rroiQ+Dx6oey3Lk=";
  };

in
rustPlatform.buildRustPackage rec {
  pname = "mavlink2rest";
  version = "1.0.0";

  commitDate = "2025-10-20T00:00:00Z";

  src = fetchFromGitHub {
    owner = "mavlink";
    repo = "mavlink2rest";
    rev = "${version}";
    hash = "sha256-yEx8c1biUlCBiSAdufuJdQhHPZOMLjL6OchqVhLwnDc=";
  };

  preConfigure = ''
    export SOURCE_DATE_EPOCH=$(date -d "${commitDate}" +%s)
    echo "Setting SOURCE_DATE_EPOCH to $SOURCE_DATE_EPOCH"
  '';

  postPatch = ''
    # Easier than generating hashes
    cp ${./mavlink2rest.lock} Cargo.lock
    chmod +w Cargo.lock
    # Git crate is looking .git folder that isn't provided
    git init && git config user.email "nix@example.com" && git config user.name "Nix Builder" && git add . && git commit -m "fake commit"
    # Adding vue styling 
    mkdir -p src/html
    cp ${vue-js} src/html/vue.global.js
    cp ${highlight-css} src/html/github.css
    cp ${highlight-js} src/html/highlight.min.js
    sed -i '/download_file(remote_file, \&artifacts_dir);/c\        continue;' build.rs
  '';

  cargoLock = {
    lockFile = ./mavlink2rest.lock;
  };
  nativeBuildInputs = [
    pkg-config
    clang
    git
  ];

  buildInputs = [ openssl ];

  LIBCLANG_PATH = "${clang.cc.lib}/lib";
  VERGEN_GIT_SHA = src.rev; # Pass the actual hash from fetchFromGitHub
  VERGEN_GIT_COMMIT_TIMESTAMP = commitDate;
  GIT_HASH = src.rev;

  meta = with lib; {
    description = "a REST server that provides mavlink information from a mavlink source";
    homepage = "https://github.com/mavlink/mavlink2rest";
    license = licenses.mit;
  };
}
