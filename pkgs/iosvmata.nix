{ lib
, stdenvNoCC
, fetchurl
, zstd }:

stdenvNoCC.mkDerivation rec {
  pname = "iosvmata";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/N-R-K/Iosvmata/releases/download/v1.2.0/Iosvmata-v1.2.0.tar.zst";
    hash = "sha256-Cq/bx+nc5sTHxb4GerpEHDmW7st835bQ6ihTOp20Ei4=";
  };

  nativeBuildInputs = [ zstd ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    runHook preInstall

    install_path=$out/share/fonts/truetype
    mkdir -p $install_path
    find Nerd -type f -name "*.ttf" -exec cp {} $install_path \;

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/N-R-K/Iosvmata";
    description = "Custom Iosevka build somewhat mimicking PragmataPro";
    platforms = platforms.all;
  };
}
