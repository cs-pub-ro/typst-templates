{
  description = "Typst runtime closure for minimal Docker image";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # List of systems we support
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper: for each system, build an attrset of packages
      perSystem = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          typstRuntime = pkgs.buildEnv {
            name = "typst-runtime";
            paths = with pkgs; [
              bashInteractive
              busybox
              coreutils
              git                 # used by typst for version metadata and by users
              typst
              fontconfig
              stdenv.cc

              # ---- Fonts ----------------------------------------------------
              # The thesis template requests "Times New Roman" (serif) and
              # "Courier New" (monospace). Those are proprietary Microsoft fonts
              # and cannot be redistributed in the image. The Liberation family
              # is metric-compatible (same glyph widths/metrics), so documents
              # render with the intended layout and full Romanian-diacritic
              # coverage. To use the *exact* Microsoft fonts, install them
              # yourself (see README) or swap the font names in thesis/main.typ.
              liberation_ttf      # Liberation Serif/Mono/Sans (Times/Courier/Arial metric clones)
              dejavu_fonts        # broad Unicode fallback
              noto-fonts          # extra Unicode coverage fallback
            ];
            pathsToLink = [ "/bin" "/share" ];
          };
        in {
          typst-runtime = typstRuntime;
        });
    in {
      # Expose them under the standard flake schema:
      # packages.<system>.typst-runtime
      packages = perSystem;
    };
}