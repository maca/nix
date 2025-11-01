{ stdenv
, lib
, faust
, qt6
}:

stdenv.mkDerivation {
  pname = "faust2caqt";
  version = faust.version;

  src = faust.src;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    faust
    qt6.qtbase
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp tools/faust2appls/faust2caqt $out/bin/
    chmod +x $out/bin/faust2caqt

    # Patch the script to use Nix store paths and add C++17 support
    substituteInPlace $out/bin/faust2caqt \
      --replace-fail "/usr/local" "${faust}" \
      --replace-fail 'qmake' '${qt6.qtbase}/bin/qmake' \
      --replace-fail 'CXXFLAGS+=" $MYGCCFLAGS"' 'CXXFLAGS+=" $MYGCCFLAGS -std=c++17"'

    runHook postInstall
  '';

  meta = with lib; {
    description = "Compile Faust programs to CoreAudio and Qt on macOS";
    homepage = "https://faust.grame.fr/";
    license = licenses.gpl2Plus;
    platforms = platforms.darwin;
    maintainers = [ ];
  };
}
