# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
#
# flake.nix - Nix flake for elegant-STATE
# Note: Guix is the primary package manager; this is a Nix fallback
# for users without Guix available.

{
  description = "elegant-STATE: Local-first state graph for multi-agent orchestration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "elegant-state-dev";

          buildInputs = with pkgs; [
            # Rust toolchain
            rustToolchain

            # Build dependencies
            pkg-config
            openssl

            # Development tools
            git
            just

            # Optional: Documentation
            # asciidoctor
          ];

          shellHook = ''
            echo "elegant-STATE development shell (Nix fallback)"
            echo "Note: Guix is the primary package manager for this project"
            echo ""
            echo "Available commands:"
            echo "  cargo build    - Build the project"
            echo "  cargo test     - Run tests"
            echo "  just           - Show available tasks"
            echo ""
          '';

          RUST_BACKTRACE = 1;
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "elegant-state";
          version = "0.1.0";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            openssl
          ];

          meta = with pkgs.lib; {
            description = "Local-first state graph for multi-agent orchestration";
            homepage = "https://github.com/hyperpolymath/elegant-STATE";
            license = with licenses; [ mit agpl3Plus ];
            maintainers = [];
          };
        };
      }
    );
}
