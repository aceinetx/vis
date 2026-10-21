{
  description = "vis";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        luaPackages = pkgs.luaPackages;
      in
      with pkgs;
      rec {
        packages = rec {
          lpeg-pc = stdenv.mkDerivation {
            pname = "lpeg-pc";
            version = luaPackages.lpeg.version;

            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;

            propagatedBuildInputs = [ luaPackages.lpeg ];

            installPhase = ''
              mkdir -p "$out/lib/pkgconfig"

              lib_path=$(dirname $(find ${luaPackages.lpeg}/lib/lua -name "lpeg.so"))

              cat > "$out/lib/pkgconfig/lpeg.pc" <<EOF
              Name: lpeg
              Description: lpeg
              Version: ${luaPackages.lpeg.version}
              Libs: -L$lib_path -l:lpeg.so -Wl,--rpath $lib_path
              EOF
            '';
          };

          vis = stdenv.mkDerivation {
            pname = "vis";
            version = "0.9";

            src = self;

            buildInputs = [
              stdenv.cc.cc
              ncurses
              luaPackages.lua
              pkg-config
              lpeg-pc
              tre
              acl
              libselinux
            ];
          };

          default = vis;
        };

        devShells.default = mkShell {
          buildInputs = [
            stdenv.cc.cc
            ncurses
            luaPackages.lua
            pkg-config
            packages.lpeg-pc
            tre
            acl
            libselinux
          ];
        };
      }
    );
}
