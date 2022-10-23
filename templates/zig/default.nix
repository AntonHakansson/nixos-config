{ clangStdenv, zig }:

clangStdenv.mkDerivation rec {
  pname = "zig-raylib-exe";
  version = "0.1.0";
  src = ./.;
  nativeBuildInputs = [ zig ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  buildPhase = ''
    runHook preBuild
    zig build -Drelease-safe -Dtarget=${clangStdenv.hostPlatform.parsed.cpu.name}-native
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp zig-out/bin/* $out/bin
  '';
}
