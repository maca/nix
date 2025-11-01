{ lib
, stdenv
, fetchFromGitHub
, tree-sitter
, nodejs
}:

stdenv.mkDerivation rec {
  pname = "tree-sitter-faust";
  version = "unstable-2025-07-01";

  src = fetchFromGitHub {
    owner = "khiner";
    repo = "tree-sitter-faust";
    rev = "122dd101919289ea809bad643712fcb483a1bed0";
    hash = "sha256-5T+Om1qdSIal1pMIoaM44FexSqZyhZCZb/Pa0/udzZI=";
  };

  nativeBuildInputs = [
    tree-sitter
    nodejs
  ];

  configurePhase = ''
    runHook preConfigure
    tree-sitter generate
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    $CC -shared -o parser.so -I src src/parser.c -O2
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp parser.so $out/lib/
    mkdir -p $out/queries
    cp queries/* $out/queries/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tree-sitter grammar for the Faust audio programming language";
    homepage = "https://github.com/khiner/tree-sitter-faust";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
