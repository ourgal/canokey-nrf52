{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.cmake
          pkgs.python3
          pkgs.git
          pkgs.gcc-arm-embedded
          pkgs.nrf5-sdk
        ];
        shellHook = ''
          git submodule update --init --recursive
          rm -rf build 2>/dev/null
          sed -i -e "/set(NRF5_SDK_DIR/d" CMakeLists.txt
          mkdir build
          cd build
          cmake \
            -DCROSS_COMPILE=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi- \
            -DNRF5_SDK_DIR=${pkgs.nrf5-sdk}/share/nRF5_SDK \
            -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake \
            -DCMAKE_BUILD_TYPE=Release ..
          make canokey_flash.uf2
        '';
      };
    };
}
