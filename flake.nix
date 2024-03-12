{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [
          (import rust-overlay)
          (self: super: {
            rustToolchain = let
              rust = super.rust-bin;
            in
              rust.stable.latest.default.override {
                targets = ["x86_64-unknown-linux-musl"];
              };
          })
        ];

        pkgs = import nixpkgs {inherit system overlays;};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bacon
            cargo-deny
            cargo-edit
            cargo-watch
            openssl
            pkg-config
            rust-analyzer
            rustToolchain
          ];
        };
      }
    );
}
