{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    name = "serene";
    src = ./src;
    pkgs = (import nixpkgs) { inherit system; };
  in {
    packages."${system}" = {
      testing = pkgs.stdenv.mkDerivation {
        inherit name src;
        dontStrip = true;
        buildInputs = [ pkgs.gcc ];
        buildPhase = let
          devbuildOpts = "-Wall -Wextra -g -O0";
        in ''
          gcc -o ./main ${devbuildOpts} $src/tests.c $src/lib.c
        '';
        installPhase = ''
          mkdir -p "$out/bin"
          cp ./main "$out/bin/${name}"
        '';
      };
      default = pkgs.stdenv.mkDerivation {
        inherit name src;
        outputs = [ "out" ];
        buildPhase = ''
          gcc -c -O2 -o ./lib.o $src/lib.c
          ar rcs ./lib.a ./lib.o
        '';
        installPhase = ''
          mkdir -p $out/include
          mkdir -p $out/lib 
          cp $src/lib.h $out/include/${name}.h
          cp ./lib.a $out/lib/${name}.a
        '';
      };
    };
    apps."${system}" = {
      default = {
        type = "app";
        program = "${self.packages."${system}".testing}/bin/${name}";
      };
    };
  };
}
