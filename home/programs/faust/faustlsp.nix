{ lib
, buildGoModule
, fetchFromGitHub
, tree-sitter
}:

buildGoModule rec {
  pname = "faustlsp";
  version = "unstable-2025-01-01";

  src = fetchFromGitHub {
    owner = "grame-cncm";
    repo = "faustlsp";
    rev = "master";
    hash = "sha256-cidOJYQf58+zS9HlTJkzUy7zStHuX8bVhf4EkG9qR5k=";
  };

  # Patch invalid go version (1.24.3 doesn't exist, should be 1.23)
  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.24.3" "go 1.23"
  '';

  buildInputs = [ tree-sitter ];

  # Use proxyVendor for CGO dependencies with C sources
  proxyVendor = true;
  vendorHash = "sha256-9qARh53TboBuTYp6kGxR53yjDkix0CKIt1VPYBmg0dY=";

  # Tests have issues with nil pointer dereference, skip them
  doCheck = false;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A Language Server Protocol implementation for the Faust programming language";
    homepage = "https://github.com/grame-cncm/faustlsp";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "faustlsp";
    platforms = platforms.all;
  };
}
