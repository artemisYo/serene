{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    name = "serene";
    src = ./src;
    pkgs = (import nixpkgs) { inherit system; };
  in {

    
    headers = pkgs.stdenv.mkDerivation {
      inherit name src;
      buildPhase = "";
      installPhase = "cp $src/lib.h $out/${name}.h";
    };
    lib = pkgs.stdenv.mkDerivation {
      inherit name src;
      buildPhase = ''
        gcc -c -O2 -o ./lib.o $src/lib.c
        ar rcs ./lib.a ./lib.o
      '';
      installPhase = ''
        mkdir -p $out/lib
        cp ./lib.a $out/lib/${name}.a
      '';
    };

    
    packages."${system}" = let
      # expects a .c file of same name in $src/
      modules = [
        "tests"
      ];
      debugOpts = "-Wall -Wextra -g -O0";
      releaseOpts = "-O2";
      commonBuildInputs = [ pkgs.gcc ];
      
      comp = (isDebug:
        "gcc -c"
        + " " + (if isDebug then debugOpts else releaseOpts)
        + " " + pkgs.lib.concatStrings
          (pkgs.lib.intersperse " "
            (map (m: "$src/" + m + ".c") modules))
      );
      link = (isDebug:
        "gcc -o ./main"
        + " " + (if isDebug then debugOpts else releaseOpts)
        + " " + pkgs.lib.concatStrings
          (pkgs.lib.intersperse " "
            (map (m: "./" + m + ".o") modules))
      );
      installPhase = ''
        mkdir -p "$out/bin"
        cp ./main "$out/bin/${name}"
      '';
    in {
      debug = pkgs.stdenv.mkDerivation {
        inherit name src installPhase;
        dontStrip = true;
        buildInputs = commonBuildInputs;
        buildPhase = ''
          ${comp true}
          ${link true}
        '';
      };
      default = pkgs.stdenv.mkDerivation {
        inherit name src installPhase;
        nativeBuildInputs = commonBuildInputs;
        buildPhase = ''
          ${comp false}
          ${link false}
        '';
      };
    };
    apps."${system}" = {
      debug = {
        type = "app";
        program = "${self.packages."${system}".debug}/bin/${name}";
      };
      default = {
        type = "app";
        program = "${self.packages."${system}".default}/bin/${name}";
      };
    };
  };
}
