{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "faustfmt";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "carn181";
    repo = "faustfmt";
    rev = "master";
    hash = "sha256-brL0bJADP4Gtx535qgTtPnI2MW+s/JpyIb0OLWNzQhg=";
  };

  cargoHash = "sha256-uwBCy52juE3YcJoackhvrHjrvcoahbnDFg74p/X3ce8=";

  meta = with lib; {
    description = "A formatter using Topiary for the Faust programming language";
    homepage = "https://github.com/carn181/faustfmt";
    license = licenses.mit; # Assuming MIT, verify in the repo
    maintainers = [ ];
    mainProgram = "faustfmt";
    platforms = platforms.all;
  };
}
