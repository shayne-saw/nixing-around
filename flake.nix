{
  description = "A minimal flake example (modern style)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      beam = pkgs.beam.packages.erlang_28;
      cassandraFHS = pkgs.buildFHSEnvBubblewrap  {
        name = "cassandra-env";
        targetPkgs = pkgs: [
          pkgs.cassandra
          pkgs.openjdk 
          pkgs.yq
          pkgs.bash
          pkgs.coreutils
        ];
        runScript = ./cassandra-fhs-entrypoint.sh;
      };
      keycloakFHS = pkgs.buildFHSEnvBubblewrap {
        name = "keycloak-env";
        targetPkgs = pkgs: [
          pkgs.keycloak
          pkgs.openjdk
        ];
        runScript = ./keycloak-fhs-entrypoint.sh;
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.fish
          pkgs.yq
          pkgs.postgresql
          beam.erlang
          beam.hex
          beam.rebar3
          beam.elixir_1_19
          cassandraFHS
          keycloakFHS
          pkgs.process-compose
          pkgs.neo4j
          pkgs.opensearch
        ];

        shellHook = ''
          export MIX_ARCHIVES=$PWD/.mix/archives
          export NEO4J_HOME=$PWD/neo4j
          export OPENSEARCH_PATH_CONF=$PWD/opensearch/config
          export SHELL=${pkgs.fish}/bin/fish
          mkdir -p $MIX_ARCHIVES
          exec ${pkgs.fish}/bin/fish -l
        '';
      };
    };
}
